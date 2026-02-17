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

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution.arn
}

output "ecs_services" {
  value = {
    food = {
      name           = aws_ecs_service.food.name
      arn            = aws_ecs_service.food.arn
      tg_arn         = aws_lb_target_group.food.arn
      path           = "/food/*"
      container_name = "food"
      port           = 8080
    }

    preference = {
      name           = aws_ecs_service.preference.name
      arn            = aws_ecs_service.preference.arn
      tg_arn         = aws_lb_target_group.preference.arn
      path           = "/preference/*"
      container_name = "preference"
      port           = 8080
    }
  }
}

output "service_urls" {
  value = {
    food       = "http://${aws_lb.app.dns_name}/food/"
    preference = "http://${aws_lb.app.dns_name}/preference/"
  }
}
