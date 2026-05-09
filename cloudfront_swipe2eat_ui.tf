# ============================================================================
# CloudFront Distribution: swipe2eat-ui (Flutter Web)
#
# 给 swipe2eat-ui 专用的 distribution，跟 admin-portal 的 aws_cloudfront_distribution.app
# 完全隔离。架构镜像现有 app distribution 的设计:
#   - default origin → 新 swipe2eat-ui S3 bucket
#   - /food/*, /user/*, /preference/*, /llm/* → ALB (跟 app distribution 共享后端)
#   - SPA fallback (403→/index.html) 服务 swipe2eat-ui 自己的 index.html
#   - 复用 WAF + security headers policy
#
# 用 CloudFront 默认证书 (dXXXXX.cloudfront.net), 暂不绑自定义域名。
# ============================================================================

# OAC (Origin Access Control): 让 CloudFront 用 SigV4 签名访问 S3
resource "aws_cloudfront_origin_access_control" "swipe2eat_ui_s3" {
  name                              = "${var.name}-swipe2eat-ui-s3-oac-${var.env}"
  description                       = "OAC for swipe2eat-ui bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "swipe2eat_ui" {
  enabled             = true
  comment             = "${var.name}-swipe2eat-ui-${var.env}"
  default_root_object = "index.html"
  web_acl_id          = aws_wafv2_web_acl.cf.arn # 复用现有 WAF

  # ------------------------ Origins ------------------------
  # Origin 1: swipe2eat-ui S3 bucket (默认 origin)
  origin {
    domain_name              = aws_s3_bucket.swipe2eat_ui.bucket_regional_domain_name
    origin_id                = "swipe2eat-ui-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.swipe2eat_ui_s3.id
  }

  # Origin 2: ALB (后端 API, 跟 admin-portal 共享同一个 ALB)
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

  # ------------------------ Default behavior ------------------------
  # 默认: 静态前端从 swipe2eat-ui S3 + 安全 headers
  default_cache_behavior {
    target_origin_id       = "swipe2eat-ui-s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
  }

  # ------------------------ Backend API routes (→ ALB) ------------------------
  # 跟 app distribution 一致，让 swipe2eat-ui 的 Flutter app 调后端 API 时
  # 不需要跨域。
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

  # ------------------------ SPA fallback ------------------------
  # 任何 S3 403 (深层路径文件不存在) → 200 + /index.html
  # 让 Flutter 的客户端路由能处理深链
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

  # 用 CloudFront 默认 TLS 证书 (dXXXXX.cloudfront.net)
  # 后续要绑自定义域名时再改
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_100" # NA + EU edge locations only, 省钱

  tags = {
    Name = "${var.name}-swipe2eat-ui-cf-${var.env}"
  }
}

# ----------------------------------------------------------------------------
# Outputs (供 swipe2eat-ui repo 配置 GitHub Variables)
# ----------------------------------------------------------------------------
output "swipe2eat_ui_cloudfront_distribution_id" {
  value       = aws_cloudfront_distribution.swipe2eat_ui.id
  description = "CloudFront distribution ID for swipe2eat-ui (used by GH Actions for invalidation)"
}

output "swipe2eat_ui_cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.swipe2eat_ui.domain_name
  description = "CloudFront default domain (dXXXXX.cloudfront.net) for swipe2eat-ui"
}

output "swipe2eat_ui_cloudfront_arn" {
  value       = aws_cloudfront_distribution.swipe2eat_ui.arn
  description = "CloudFront distribution ARN for swipe2eat-ui (referenced by IAM policy and S3 bucket policy)"
}
