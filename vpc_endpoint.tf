resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.id}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.app.id,
    aws_route_table.db.id,
    aws_route_table.reserved.id
  ]

  tags = {
    Name = "${var.name}-vpce-s3-${var.env}"
  }
}
