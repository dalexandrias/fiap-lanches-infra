resource "tls_private_key" "service" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "service_private_key" {
  content  = tls_private_key.service.private_key_pem
  filename = aws_key_pair.ssh_keypair.key_name
  provisioner "local-exec" {
    command = "chmod 400 ${aws_key_pair.ssh_keypair.key_name}"
  }
}

resource "aws_key_pair" "ssh_keypair" {
  key_name   = "${var.app_name}-key-pair-ec2"
  public_key = tls_private_key.service.public_key_openssh
}

resource "aws_docdb_subnet_group" "document_db_subnet_group" {
  name       = "${var.app_name}-document-db-subnet-group"
  subnet_ids = aws_subnet.private.*.id
}

resource "aws_docdb_cluster_parameter_group" "mongo_db_parameter_group" {
  family      = "docdb4.0"
  name        = "${var.app_name}-mongo-parameter-group"
  description = "docdb cluster parameter group"

  parameter {
    name  = "tls"
    value = "disable"
  }
}

resource "aws_docdb_cluster" "document_db_cluster" {
  cluster_identifier              = "${var.app_name}-document-db-cluster"
  availability_zones              = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  engine_version                  = "4.0.0"
  master_username                 = "fiap_lanches"
  master_password                 = "fiaplanches123"
  backup_retention_period         = 5
  preferred_backup_window         = "07:00-09:00"
  skip_final_snapshot             = true
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.mongo_db_parameter_group.name
  db_subnet_group_name            = aws_docdb_subnet_group.document_db_subnet_group.name
  vpc_security_group_ids          = [aws_security_group.document_db_mongo_security_group.id]
}

resource "aws_docdb_cluster_instance" "document_db_instance" {
  identifier         = "docdb-cluster-instance"
  cluster_identifier = aws_docdb_cluster.document_db_cluster.id
  instance_class     = "db.t3.medium"
}

resource "aws_instance" "mongo_db_instance" {
  ami                         = "ami-0fc5d935ebf8bc3bc"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.ssh_keypair.key_name
  subnet_id                   = element(aws_subnet.public.*.id, 0)
  security_groups             = [aws_security_group.ec2_mongo_db_security_group.id]
  associate_public_ip_address = true
  user_data                   = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install gnupg curl
              curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
              gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
              --dearmor
              echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
              apt-get update
              apt-get install -y mongodb-org
              systemctl start mongod
              systemctl enable mongodb
              EOF
  tags = {
    Name = "my-ssh-tunnel-server"
  }
}

