resource "aws_db_subnet_group" "database_subnet_group" {
  name        = "${var.app_name}-rds-postgres-subnets"
  subnet_ids  = aws_subnet.private.*.id
  description = "Subnets para o rds postgres"

  tags = {
    Name = "${var.app_name}-subnet-rds-postgres"
  }

  depends_on = [aws_vpc.main, aws_subnet.private, aws_subnet.public]
}

resource "aws_db_instance" "db_instance" {
  engine                 = "postgres"
  engine_version         = "15.3"
  multi_az               = false
  identifier             = "${var.app_name}-rds-postgres"
  username               = "fiap_lanches"
  password               = "fiaplanches123"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  db_subnet_group_name   = aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids = [aws_security_group.database_security_group.id]
  count                  = var.az_count
  availability_zone      = data.aws_availability_zones.available.names[count.index]
  db_name                = "fiaplanches"
  skip_final_snapshot    = true
  # publicly_accessible    = true

  depends_on = [aws_db_subnet_group.database_subnet_group]
}
