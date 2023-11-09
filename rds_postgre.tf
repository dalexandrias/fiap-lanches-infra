
resource "aws_security_group" "database_security_group" {
  name        = "${var.environment}-rds-postgres-sg"
  description = "Liberacao da porta 5432 para acesso ao rds postgres"
  vpc_id      = aws_vpc.vpc.id
  depends_on = [
    aws_vpc.vpc
  ]

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.default.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = "${var.environment}-rds-postgres"
  }
}

resource "aws_db_subnet_group" "database_subnet_group" {
  name        = "${var.app_name}-rds-postgres-subnets"
  subnet_ids  = [element(aws_subnet.private_subnet.*.id, 0), element(aws_subnet.subnet.*.id, 0)]
  description = "Subnets para o rds postgres"

  tags = {
    Name = "${var.app_name}-subnet-rds-postgres"
  }
}

resource "aws_db_instance" "db_instance" {
  engine                 = "postgres"
  engine_version         = "14"
  multi_az               = false
  identifier             = "${var.environment}-rds-postgres"
  username               = "fiap_lanches"
  password               = "fiaplanches123"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  db_subnet_group_name   = aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids = [aws_security_group.database_security_group.id]
  availability_zone      = data.aws_availability_zones.available.names[0]
  db_name                = "${var.environment}-db"
  skip_final_snapshot    = true
}


# module "db" {
#   source = "terraform-aws-modules/rds/aws"

#   identifier = "${var.app_name}-db"

#   engine               = "postgres"
#   engine_version       = "14"
#   instance_class       = "db.t3.micro"
#   major_engine_version = "14"
#   allocated_storage    = 5

#   db_name  = "fiaplanches"
#   username = "fiap_lanches"
#   port     = "5432"

#   iam_database_authentication_enabled = false

#   vpc_security_group_ids = [aws_security_group.default.id]

#   maintenance_window = "Mon:00:00-Mon:03:00"
#   backup_window      = "03:00-06:00"

#   # Enhanced Monitoring - see example for details on how to create the role
#   # by yourself, in case you don't want to create it automatically
#   monitoring_interval    = "30"
#   monitoring_role_name   = "${var.app_name}-Role"
#   create_monitoring_role = true

#   tags = {
#     Owner       = "${var.app_name}"
#     Environment = "${var.environment}"
#   }

#   # DB subnet group
#   subnet_ids = [element(aws_subnet.private_subnet.*.id, 0)]

#   # DB parameter group
#   family = "postgres14"

#   # Database Deletion Protection
#   deletion_protection = false
# }
