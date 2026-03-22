resource "aws_db_instance" "postgres" {
  identifier = "${var.name}-pg-${var.env}"

  engine         = "postgres"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = var.postgres_db_name
  username = var.postgres_db_username
  password = var.postgres_db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period    = 0
  skip_final_snapshot        = true
  deletion_protection        = false
  snapshot_identifier        = "keisnapshot"
  auto_minor_version_upgrade = false
}