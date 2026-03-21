variable "env" {
  type    = string
  default = "dev"
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-1" # sg 
}

variable "name" {
  type    = string
  default = "swe5006-nus-g3"
}

variable "domain_name" {
  type    = string
  default = ""
}

# RDS
variable "postgres_db_username" {
  type      = string
  sensitive = true
}

variable "postgres_db_password" {
  type      = string
  sensitive = true
}

variable "postgres_db_name" {
  type    = string
  default = "appdb"
}

# ECS
variable "app_port" {
  type    = number
  default = 8080
}

variable "health_check_path" {
  type    = string
  default = "/health"
}

variable "food_image" {
  type    = string
  default = "keiyam/placeholder:85f6ecc"
}

variable "preference_image" {
  type    = string
  default = "keiyam/placeholder:85f6ecc"
}

variable "user_image" {
  type    = string
  default = "keiyam/placeholder:85f6ecc"
}

# Cognito
variable "admin_callback_urls" {
  type    = list(string)
  default = ["https://${var.env}.${var.domain_name}/callback"]
}

variable "admin_logout_urls" {
  type    = list(string)
  default = ["https://${var.env}.${var.domain_name}/logout"]
}

variable "cognito_domain_prefix" {
  type    = string
  default = "swe5006-nus-g3"
}