resource "aws_secretsmanager_secret" "postgres" {
  name = "${var.name}/postgres/${var.env}"
}

resource "aws_secretsmanager_secret_version" "postgres" {
  secret_id = aws_secretsmanager_secret.postgres.id

  secret_string = jsonencode({
    username = var.postgres_db_username
    password = var.postgres_db_password

    host   = aws_db_instance.postgres.address
    port   = 5432
    dbname = var.postgres_db_name

    url = "postgresql://${var.postgres_db_username}:${var.postgres_db_password}@${aws_db_instance.postgres.address}:5432/${var.postgres_db_name}"
  })
}

output "postgres_secret_arn" {
  value = aws_secretsmanager_secret.postgres.arn
}

// for this iam role needs to be given to ecs
resource "aws_iam_role_policy" "ecs_task_read_postgres_secret" {
  name = "${var.name}-ecs-exec-read-db-secret-${var.env}"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = aws_secretsmanager_secret.postgres.arn
      }
    ]
  })
}

resource "aws_secretsmanager_secret" "aws_keys" {
  name = "${var.name}/aws-access-keys/${var.env}"
}

resource "aws_secretsmanager_secret_version" "aws_keys" {
  secret_id = aws_secretsmanager_secret.aws_keys.id

  secret_string = jsonencode({
    aws_access_key_id     = var.aws_iam_access_key_id
    aws_secret_access_key = var.aws_iam_access_key_secret
  })
}

output "aws_keys_secret_arn" {
  value = aws_secretsmanager_secret.aws_keys.arn
}