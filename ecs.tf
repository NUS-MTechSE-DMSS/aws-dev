resource "aws_ecs_cluster" "this" {
  name = "${var.name}-ecs-${var.env}"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.name}-${var.env}"
  retention_in_days = 1
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.name}-ecs-task-exec-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
