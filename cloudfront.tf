data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}

resource "aws_cloudfront_origin_access_control" "public_s3" {
  name                              = "${var.name}-public-s3-oac-${var.env}"
  description                       = "OAC for public bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "app" {
  enabled             = true
  comment             = "${var.name}-${var.env}"
  default_root_object = "index.html"
  web_acl_id          = aws_wafv2_web_acl.cf.arn

  origin {
    domain_name              = aws_s3_bucket.public.bucket_regional_domain_name
    origin_id                = "public-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.public_s3.id
  }

  # Origin 2: swipe2eat-ui S3 bucket（staging 子路径）
  origin {
    domain_name              = aws_s3_bucket.swipe2eat_ui.bucket_regional_domain_name
    origin_id                = "swipe2eat-ui-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.swipe2eat_ui_s3.id
  }

  origin {
    domain_name = var.origin_domain_name
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_read_timeout      = 60
      origin_keepalive_timeout = 60
    }
  }

  default_cache_behavior {
    target_origin_id       = "public-s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
  }

  #   default_cache_behavior {
  #     target_origin_id       = "alb-origin"
  #     viewer_protocol_policy = "redirect-to-https"
  #     compress               = true

  #     allowed_methods = ["GET", "HEAD", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
  #     cached_methods  = ["GET", "HEAD"]

  #     cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
  #     origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
  #   }

  # /staging/* → swipe2eat-ui S3 bucket（URL rewrite: /staging/sha/ → /staging/sha/index.html）
  ordered_cache_behavior {
    path_pattern           = "/staging/*"
    target_origin_id       = "swipe2eat-ui-s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.swipe2eat_ui_rewrite.arn
    }
  }

  ordered_cache_behavior {
    path_pattern           = "/food*"
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
  }

  ordered_cache_behavior {
    path_pattern           = "/user*"
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
  }

  ordered_cache_behavior {
    path_pattern           = "/preference*"
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
  }

  ordered_cache_behavior {
    path_pattern           = "/llm*"
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.domain_name == ""
    acm_certificate_arn            = var.domain_name != "" ? aws_acm_certificate_validation.cf.certificate_arn : null
    ssl_support_method             = var.domain_name != "" ? "sni-only" : null
    minimum_protocol_version       = var.domain_name != "" ? "TLSv1.2_2021" : "TLSv1"
  }

  aliases = var.domain_name != "" ? [var.domain_name] : []

  price_class = "PriceClass_100"

  tags = {
    Name = "${var.name}-cf-${var.env}"
  }
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.app.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.app.id
}