variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_a = data.aws_availability_zones.available.names[0]
  az_b = data.aws_availability_zones.available.names[1]

  public_a_cidr   = cidrsubnet(var.vpc_cidr, 8, 0)  # 10.0.0.0/24
  public_b_cidr   = cidrsubnet(var.vpc_cidr, 8, 1)  # 10.0.1.0/24
  app_a_cidr      = cidrsubnet(var.vpc_cidr, 8, 10) # 10.0.10.0/24
  app_b_cidr      = cidrsubnet(var.vpc_cidr, 8, 11) # 10.0.11.0/24
  db_a_cidr       = cidrsubnet(var.vpc_cidr, 8, 20) # 10.0.20.0/24
  db_b_cidr       = cidrsubnet(var.vpc_cidr, 8, 21) # 10.0.21.0/24
  reserved_a_cidr = cidrsubnet(var.vpc_cidr, 8, 30) # 10.0.30.0/24
  reserved_b_cidr = cidrsubnet(var.vpc_cidr, 8, 31) # 10.0.31.0/24
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-vpc-${var.env}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw-${var.env}"
  }
}
