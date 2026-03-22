resource "aws_cognito_user_group" "admin" {
  user_pool_id = aws_cognito_user_pool.this.id
  name         = "admin"
  description  = "Admin users"
  precedence   = 1
}

resource "aws_cognito_user_group" "app_user" {
  user_pool_id = aws_cognito_user_pool.this.id
  name         = "app-user"
  description  = "Normal application users"
  precedence   = 2
}

# web client
resource "aws_cognito_user_pool_client" "web" {
  name         = "${var.name}-web-client-${var.env}"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = true

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]

  callback_urls = var.cognito_callback_urls
  logout_urls   = var.cognito_logout_urls

  supported_identity_providers = ["COGNITO"]

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

# mobile client
resource "aws_cognito_user_pool_client" "mobile" {
  name         = "${var.name}-mobile-client-${var.env}"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  read_attributes = [
    "email",
    "custom:city"
  ]

  write_attributes = [
    "email",
    "custom:city"
  ]
}

resource "aws_cognito_user_pool_client" "test" {
  name         = "${var.name}-test-client-${var.env}"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret                      = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]

  callback_urls = var.cognito_callback_urls
  logout_urls   = var.cognito_logout_urls

  supported_identity_providers = ["COGNITO"]

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

output "cognito_web_client_id" {
  value = aws_cognito_user_pool_client.web.id
}

output "cognito_mobile_client_id" {
  value = aws_cognito_user_pool_client.mobile.id
}

output "cognito_admin_group_name" {
  value = aws_cognito_user_group.admin.name
}

output "cognito_app_user_group_name" {
  value = aws_cognito_user_group.app_user.name
}

output "cognito_web_login_url" {
  value = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.current.id}.amazoncognito.com/login?client_id=${aws_cognito_user_pool_client.web.id}&response_type=code&scope=openid+email+profile&redirect_uri=${urlencode(var.cognito_callback_urls[0])}"
}

output "cognito_test_login_url" {
  value = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.current.id}.amazoncognito.com/login?client_id=${aws_cognito_user_pool_client.test.id}&response_type=code&scope=openid+email+profile&redirect_uri=${urlencode("https://dev.keiyam.me/oauth2/idpresponse")}"
}