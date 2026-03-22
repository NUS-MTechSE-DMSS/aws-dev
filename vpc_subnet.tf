# public
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = local.az_a
  cidr_block              = local.public_a_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-a-${var.env}"
    Tier = "public"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = local.az_b
  cidr_block              = local.public_b_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-b-${var.env}"
    Tier = "public"
  }
}

# app
resource "aws_subnet" "app_a" {
  vpc_id            = aws_vpc.this.id
  availability_zone = local.az_a
  cidr_block        = local.app_a_cidr

  tags = {
    Name = "${var.name}-app-a-${var.env}"
    Tier = "app"
  }
}

resource "aws_subnet" "app_b" {
  vpc_id            = aws_vpc.this.id
  availability_zone = local.az_b
  cidr_block        = local.app_b_cidr

  tags = {
    Name = "${var.name}-app-b-${var.env}"
    Tier = "app"
  }
}

# db
resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-dbsubnet-${var.env}-v2"
  subnet_ids = [aws_subnet.db_a.id, aws_subnet.db_b.id]

  tags = {
    Name = "${var.name}-dbsubnet-${var.env}-v2"
  }
}

resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.this.id
  availability_zone = local.az_a
  cidr_block        = local.db_a_cidr

  tags = {
    Name = "${var.name}-db-a-${var.env}"
    Tier = "db"
  }
}

resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.this.id
  availability_zone = local.az_b
  cidr_block        = local.db_b_cidr

  tags = {
    Name = "${var.name}-db-b-${var.env}"
    Tier = "db"
  }
}

# reserved
resource "aws_subnet" "reserved_a" {
  vpc_id            = aws_vpc.this.id
  availability_zone = local.az_a
  cidr_block        = local.reserved_a_cidr

  tags = {
    Name = "${var.name}-reserved-a-${var.env}"
    Tier = "reserved"
  }
}

resource "aws_subnet" "reserved_b" {
  vpc_id            = aws_vpc.this.id
  availability_zone = local.az_b
  cidr_block        = local.reserved_b_cidr

  tags = {
    Name = "${var.name}-reserved-b-${var.env}"
    Tier = "reserved"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.name}-nat-eip-${var.env}"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.allocation_id
  subnet_id     = aws_subnet.public_a.id

  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = "${var.name}-nat-${var.env}"
  }
}