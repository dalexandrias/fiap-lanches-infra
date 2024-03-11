# outputs.tf

output "alb_hostname_conta" {
  value = aws_alb.alb_conta_app.name
}

output "alb_hostname_product" {
  value = aws_alb.alb_product_app.name
}

# output "dns_broker" {
#   value = aws_msk_cluster.kafka.bootstrap_brokers
# }

output "dns_banco_rds" {
  value = aws_db_instance.db_instance.endpoint
}
