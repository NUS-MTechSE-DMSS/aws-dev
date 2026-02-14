terraform {
  required_version = "1.14.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.31"
    }
  }

  backend "s3" {
    bucket  = "swe5006-nus-g3-tfstate-dev-ap-southeast-1"
    key     = "dev/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}