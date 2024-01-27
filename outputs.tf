# outputs.tf

output "alb_hostname" {
  value = aws_alb.main.dns_name
}

# output "dns_broker" {
#   value = aws_msk_cluster.kafka.bootstrap_brokers
# }

output "dns_banco_rds" {
  value = aws_db_instance.db_instance.endpoint
}
