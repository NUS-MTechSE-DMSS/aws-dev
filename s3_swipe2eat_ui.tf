# ============================================================================
# S3 Bucket: swipe2eat-ui Frontend (Flutter Web)
#
# 给 swipe2eat-ui (Flutter web) 专用，跟 admin-portal 用的 public bucket 完全
# 隔离。访问通过 CloudFront + OAC (Origin Access Control) + SigV4 签名，bucket
# 本身不对公网开放 (Defense in Depth, 比 public bucket 更严的姿势)。
#
# NUS SE 课映射:
#   - Defense in Depth: 即使 CloudFront 出问题，bucket 内容也不裸奔
#   - Principle of Least Privilege: bucket policy 只放给唯一一个 distribution
# ============================================================================

resource "aws_s3_bucket" "swipe2eat_ui" {
  bucket        = "${var.name}-swipe2eat-ui-${var.env}-${data.aws_region.current.id}-${data.aws_caller_identity.current.account_id}"
  force_destroy = false

  tags = {
    Name = "${var.name}-swipe2eat-ui-bucket"
  }
}

# 全部关闭公网访问 — 仅 CloudFront via OAC 可读
resource "aws_s3_bucket_public_access_block" "swipe2eat_ui" {
  bucket = aws_s3_bucket.swipe2eat_ui.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy: 仅允许 swipe2eat_ui CloudFront distribution 通过 OAC 读
# 通过 AWS:SourceArn condition 限定来源 distribution
resource "aws_s3_bucket_policy" "swipe2eat_ui" {
  bucket     = aws_s3_bucket.swipe2eat_ui.id
  depends_on = [aws_s3_bucket_public_access_block.swipe2eat_ui]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCloudFrontServicePrincipalRead"
      Effect = "Allow"
      Principal = {
        Service = "cloudfront.amazonaws.com"
      }
      Action   = ["s3:GetObject"]
      Resource = "${aws_s3_bucket.swipe2eat_ui.arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.swipe2eat_ui.arn
        }
      }
    }]
  })
}

# 服务端加密 (跟 public bucket 一致)
resource "aws_s3_bucket_server_side_encryption_configuration" "swipe2eat_ui" {
  bucket = aws_s3_bucket.swipe2eat_ui.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ----------------------------------------------------------------------------
# Outputs
# ----------------------------------------------------------------------------
output "swipe2eat_ui_bucket_name" {
  value       = aws_s3_bucket.swipe2eat_ui.bucket
  description = "S3 bucket name dedicated to swipe2eat-ui Flutter web deploy"
}

output "swipe2eat_ui_bucket_arn" {
  value       = aws_s3_bucket.swipe2eat_ui.arn
  description = "S3 bucket ARN for swipe2eat-ui (referenced by IAM policy)"
}
