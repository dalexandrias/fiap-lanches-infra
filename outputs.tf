# outputs.tf

output "alb_hostname_conta" {
  value = aws_alb.main.dns_name
}

output "dns_broker" {
  value = aws_msk_cluster.kafka.bootstrap_brokers
}

output "aws_instance_public_dns" {
  value = aws_instance.mongo_db_instance.public_dns
}

output "docdb_endpoint" {
  value = aws_docdb_cluster.document_db_cluster.endpoint
}

output "docdb_username" {
  value = aws_docdb_cluster.document_db_cluster.master_username
}

output "dns_banco_rds" {
  value = aws_db_instance.db_instance.endpoint
}
