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
  default = "dev.keiyam.me"
}

variable "origin_domain_name" {
  type    = string
  default = "origin.dev.keiyam.me"
}

variable "aws_iam_access_key_id" {
  type      = string
  sensitive = true
}

variable "aws_iam_access_key_secret" {
  type      = string
  sensitive = true
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
variable "cognito_callback_urls" {
  type    = list(string)
  default = ["https://dev.keiyam.me/oauth2/idpresponse"]
}

variable "cognito_logout_urls" {
  type    = list(string)
  default = ["https://dev.keiyam.me/logout"]
}

variable "cognito_domain_prefix" {
  type    = string
  default = "swe5006-nus-g3"
}