resource "aws_cognito_user_pool" "this" {
  name                = "${var.name}-user-pool-${var.env}"
  username_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }

  auto_verified_attributes = ["email"]


  schema {
    attribute_data_type = "String"
    name                = "city"
    required            = false
    mutable             = true

    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  tags = {
    Environment = var.env
    ManagedBy   = "terraform"
  }
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = "${var.cognito_domain_prefix}-${var.env}"
  user_pool_id = aws_cognito_user_pool.this.id
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "cognito_domain" {
  value = aws_cognito_user_pool_domain.this.domain
}

