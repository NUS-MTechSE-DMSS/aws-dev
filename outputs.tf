output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "subnet_id" {
  value = data.aws_subnets.default.ids
}

output "public_bucket_name" {
  value = aws_s3_bucket.public.bucket
}

output "security_groups" {
  value = {
    alb = aws_security_group.alb.id
    db  = aws_security_group.db.id
  }
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "postgres_endpoint" {
  value = aws_db_instance.postgres.endpoint
}