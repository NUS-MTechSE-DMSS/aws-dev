resource "aws_ecs_cluster" "this" {
  name = "${var.name}-ecs-dev"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.name}-dev"
  retention_in_days = 1
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.name}-ecs-task-exec-dev"

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

# todo S3 write
# resource "aws_iam_role" "ecs_task_app" {
#   name = "${var.name}-ecs-task-app-dev"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect    = "Allow"
#       Principal = { Service = "ecs-tasks.amazonaws.com" }
#       Action    = "sts:AssumeRole"
#     }]
#   })
# }
