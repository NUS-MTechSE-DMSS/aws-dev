resource "aws_s3_bucket" "public" {
  bucket        = "${var.name}-public-dev-${data.aws_region.current.id}-${data.aws_caller_identity.current.account_id}"
  force_destroy = false

  tags = {
    Name = "${var.name}-public-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.public.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket     = aws_s3_bucket.public.id
  depends_on = [aws_s3_bucket_public_access_block.public]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = ["s3:GetObject"]
      Resource  = "${aws_s3_bucket.public.arn}/*"
    }]
  })
}

resource "aws_s3_bucket_website_configuration" "public" {
  bucket = aws_s3_bucket.public.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "public" {
  bucket = aws_s3_bucket.public.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_notification" "public_index_html_upload" {
  bucket = aws_s3_bucket.public.id

  lambda_function {
    lambda_function_arn = var.cloudfront_invalidation_lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = "index.html"
  }
}

resource "aws_s3_bucket" "admin" {
  bucket        = "${var.name}-admin-${var.env}-${data.aws_region.current.id}-${data.aws_caller_identity.current.account_id}"
  force_destroy = false

  tags = {
    Name = "${var.name}-admin-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "admin" {
  bucket = aws_s3_bucket.admin.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "admin_public_read" {
  bucket     = aws_s3_bucket.admin.id
  depends_on = [aws_s3_bucket_public_access_block.admin]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = ["s3:GetObject"]
      Resource  = "${aws_s3_bucket.admin.arn}/*"
    }]
  })
}

resource "aws_s3_bucket_website_configuration" "admin" {
  bucket = aws_s3_bucket.admin.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "admin" {
  bucket = aws_s3_bucket.admin.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}