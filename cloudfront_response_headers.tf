# ============================================================================
# CloudFront Response Headers Policy
#
# 等价于 swipe2eat-ui/netlify.toml [[headers]] 块。把 Netlify 在边缘节点
# 注入的 5 个 security headers 迁移到 CloudFront 的 managed policy。
#
# 这个 policy 会被 attach 到 cloudfront.tf 的 default_cache_behavior（即所有
# 命中 S3 origin 的请求 — HTML / JS / CSS / 图片等前端资源）。
#
# 不会 attach 到 ordered_cache_behavior（/food*, /user*, /preference*, /llm*）
# 因为那些是后端 API，由 ALB origin 自己负责响应头。
# ============================================================================

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name    = "${var.name}-security-headers-${var.env}"
  comment = "Security headers equivalent to swipe2eat-ui netlify.toml"

  security_headers_config {
    # X-Frame-Options: DENY
    # 防止页面被 iframe 嵌入（clickjacking 防护）
    frame_options {
      frame_option = "DENY"
      override     = true
    }

    # X-Content-Type-Options: nosniff
    # 阻止浏览器 MIME-type sniffing，强制使用响应里声明的 Content-Type
    content_type_options {
      override = true
    }

    # Referrer-Policy: strict-origin-when-cross-origin
    # 跨域请求时只发送 origin（隐私保护，平衡可用性）
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }

    # Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
    # HSTS — 强制浏览器一年内只用 HTTPS 访问本域名（防 SSL stripping）
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
  }

  # Permissions-Policy 不在 CloudFront 的标准 security_headers_config 里，
  # 用 custom_headers_config 显式注入。
  # 等价于 netlify.toml: Permissions-Policy = "geolocation=(), camera=(), microphone=()"
  custom_headers_config {
    items {
      header   = "Permissions-Policy"
      value    = "geolocation=(), camera=(), microphone=()"
      override = true
    }
  }
}

output "security_headers_policy_id" {
  value       = aws_cloudfront_response_headers_policy.security_headers.id
  description = "ID of the CloudFront Response Headers Policy applied to the static frontend"
}
