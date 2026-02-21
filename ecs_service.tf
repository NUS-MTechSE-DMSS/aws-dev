resource "aws_ecs_service" "food" {
  name            = "${var.name}-food"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.food.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.food.arn
    container_name   = "food"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.http]

  lifecycle {
    ignore_changes = [
      task_definition, # Harness managess
    ]
  }
}

resource "aws_ecs_service" "preference" {
  name            = "${var.name}-preference"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.preference.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.preference.arn
    container_name   = "preference"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.http]

  lifecycle {
    ignore_changes = [
      task_definition,
    ]
  }
}

resource "aws_ecs_service" "user" {
  name            = "${var.name}-user"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.user.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.user.arn
    container_name   = "user"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.http]

  lifecycle {
    ignore_changes = [
      task_definition,
    ]
  }
}
