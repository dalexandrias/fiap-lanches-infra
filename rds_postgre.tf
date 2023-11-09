module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.app_name}-db"

  engine               = "postgresql"
  engine_version       = "14"
  instance_class       = "db.t3.micro"
  major_engine_version = "14"
  allocated_storage    = 5

  db_name  = "fiaplanches"
  username = "fiap_lanches"
  port     = "5432"

  iam_database_authentication_enabled = false

  vpc_security_group_ids = [aws_security_group.default.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "${var.app_name}-Role"
  create_monitoring_role = true

  tags = {
    Owner       = "${var.app_name}"
    Environment = "${var.environment}"
  }

  # DB subnet group
  subnet_ids = [element(aws_subnet.private_subnet.*.id, 0)]

  # DB parameter group
  family = "postgres14"

  # Database Deletion Protection
  deletion_protection = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]
}
