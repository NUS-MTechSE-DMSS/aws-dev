resource "aws_s3_bucket" "public" {
  bucket        = "${var.name}-public-dev-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
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