resource "aws_ecs_service" "food" {
  name            = "${var.name}-food-${var.env}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.food.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.app_a.id, aws_subnet.app_b.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.food.arn
    container_name   = "food"
    container_port   = 8080
  }

  # http://food.${var.name}.internal:8080
  service_registries {
    registry_arn   = aws_service_discovery_service.food.arn
    container_name = "food"
  }

  depends_on = [aws_lb_listener_rule.food]
  lifecycle {
    ignore_changes = [
      task_definition, # Harness managess
    ]
  }
}

resource "aws_ecs_service" "preference" {
  name            = "${var.name}-preference-${var.env}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.preference.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.app_a.id, aws_subnet.app_b.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.preference.arn
    container_name   = "preference"
    container_port   = 8080
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.preference.arn
    container_name = "preference"
  }

  depends_on = [aws_lb_listener_rule.preference]
  lifecycle {
    ignore_changes = [
      task_definition,
    ]
  }
}

resource "aws_ecs_service" "user" {
  name            = "${var.name}-user-${var.env}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.user.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.app_a.id, aws_subnet.app_b.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.user.arn
    container_name   = "user"
    container_port   = 8080
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.user.arn
    container_name = "user"
  }

  depends_on = [aws_lb_listener_rule.user]
  lifecycle {
    ignore_changes = [
      task_definition,
    ]
  }
}

resource "aws_ecs_service" "llm" {
  name            = "${var.name}-llm-${var.env}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.llm.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = 300

  network_configuration {
    subnets          = [aws_subnet.app_a.id, aws_subnet.app_b.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.llm.arn
    container_name   = "llm"
    container_port   = 8080
  }

  # http://llm.${var.name}.internal:8080
  service_registries {
    registry_arn   = aws_service_discovery_service.llm.arn
    container_name = "llm"
  }

  depends_on = [aws_lb_listener_rule.llm]
  lifecycle {
    ignore_changes = [
      task_definition, # Harness manages
    ]
  }
}
