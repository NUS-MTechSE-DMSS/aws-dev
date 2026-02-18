variable "aws_region" {
  type    = string
  default = "ap-southeast-1" # sg 
}

variable "name" {
  type    = string
  default = "swe5006-nus-g3"
}

variable "postgres_db_username" {
  type      = string
  sensitive = true
}

variable "postgres_db_password" {
  type      = string
  sensitive = true
}

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
