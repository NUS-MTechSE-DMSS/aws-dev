# ============================================================================
# GitHub Actions OIDC Provider + IAM Role for swipe2eat-ui Deployment
#
# 让 GitHub Actions 不用长期 access key，而是通过 OIDC 拿临时凭证。
#
# 工作原理:
#   1. swipe2eat-ui 的 GH workflow 执行时，GitHub 给它发一个短期 OIDC token
#      (claims 里包含 repo / branch / workflow 信息)
#   2. workflow 用这个 token 调 sts:AssumeRoleWithWebIdentity
#   3. AWS 验证 token 签名 + 检查 trust policy 的 condition
#   4. 通过则发临时 STS 凭证（默认 1 小时），用来跑 aws s3 sync 等命令
#
# NUS SE 课映射:
#   - Principle of Least Privilege: IAM policy 精确到 action + resource
#   - Secret Management: 临时凭证替代长期 access key
#   - DevSecOps: 凭证泄露的 blast radius 从永久变为 1 小时
# ============================================================================

# ----------------------------------------------------------------------------
# OIDC Provider (account-wide, only one per account)
# ----------------------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  # GitHub 自 2023 起 AWS IAM 自动验证 OIDC 证书，thumbprint 主要历史兼容
  # 这两个是 GitHub 当前+轮换的 root CA thumbprint
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]

  tags = {
    Name = "${var.name}-github-oidc-${var.env}"
  }
}

# ----------------------------------------------------------------------------
# IAM Role: 仅 swipe2eat-ui repo 可 assume
# ----------------------------------------------------------------------------
resource "aws_iam_role" "github_swipe2eat_ui_deploy" {
  name = "${var.name}-gh-swipe2eat-ui-deploy-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          # 必须是 GitHub OIDC 给 AWS STS 的 token
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          # 仅信任 NUS-MTechSE-DMSS/swipe2eat-ui 这一个 repo
          # `:*` 表示任何 branch/tag/PR/environment 都允许
          # (release.yml 是手动触发, staging-deploy.yml 跑在 main)
          "token.actions.githubusercontent.com:sub" = "repo:NUS-MTechSE-DMSS/swipe2eat-ui:*"
        }
      }
    }]
  })

  tags = {
    Name = "${var.name}-gh-swipe2eat-ui-deploy-${var.env}"
  }
}

# ----------------------------------------------------------------------------
# Inline Policy: 最小权限
#   - S3: 仅 swipe2eat-ui bucket 的对象读写 (跟 admin-portal 的 public bucket 完全隔离)
#   - CloudFront: 仅 swipe2eat-ui distribution 的缓存刷新
#
# 不允许:
#   - 触碰 public bucket (admin-portal 的) 或 admin bucket
#   - 删除 bucket / distribution 本身
#   - 修改 bucket policy / distribution config
# ----------------------------------------------------------------------------
resource "aws_iam_role_policy" "github_swipe2eat_ui_deploy" {
  name = "swipe2eat-ui-deploy-policy"
  role = aws_iam_role.github_swipe2eat_ui_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Swipe2eatUiBucketObjectReadWrite"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:DeleteObject",
        ]
        Resource = "${aws_s3_bucket.swipe2eat_ui.arn}/*"
      },
      {
        # `aws s3 sync` 需要 ListBucket 才能比对 source/destination
        Sid      = "Swipe2eatUiBucketList"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.swipe2eat_ui.arn
      },
      {
        Sid    = "Swipe2eatUiCloudFrontInvalidationOnly"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation",
          "cloudfront:ListInvalidations",
        ]
        Resource = [
          aws_cloudfront_distribution.swipe2eat_ui.arn,
          aws_cloudfront_distribution.app.arn,
        ]
      },
    ]
  })
}

# ----------------------------------------------------------------------------
# Outputs (供 swipe2eat-ui repo 配置 GitHub Variables 使用)
# ----------------------------------------------------------------------------
output "github_actions_role_arn" {
  value       = aws_iam_role.github_swipe2eat_ui_deploy.arn
  description = "ARN of the IAM Role assumed by swipe2eat-ui GitHub Actions via OIDC"
}
