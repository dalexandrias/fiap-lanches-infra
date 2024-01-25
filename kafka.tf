# resource "aws_kms_key" "kafka_kms_key" {
#   description = "fiaplanches123"
# }

# resource "aws_cloudwatch_log_group" "kafka_log_group" {
#   name = "kafka_broker_logs"
# }

# resource "aws_msk_configuration" "kafka_config" {
#   kafka_versions    = ["3.4.0"]
#   name              = "${var.global_prefix}-config"
#   server_properties = <<EOF
# auto.create.topics.enable = true
# delete.topic.enable = true
# EOF
# }

# resource "aws_msk_cluster" "kafka" {
#   cluster_name           = var.global_prefix
#   kafka_version          = "3.4.0"
#   number_of_broker_nodes = length(data.aws_availability_zones.available.names)
#   broker_node_group_info {
#     instance_type = "kafka.m5.large" # default value
#     storage_info {
#       ebs_storage_info {
#         volume_size = 1000
#       }
#     }
#     client_subnets  = [element(aws_subnet.private_subnet_1.*.id, 0), element(aws_subnet.private_subnet_2.*.id, 0)]
#     security_groups = [aws_security_group.kafka.id]
#   }
#   encryption_info {
#     encryption_in_transit {
#       client_broker = "PLAINTEXT"
#     }
#     encryption_at_rest_kms_key_arn = aws_kms_key.kafka_kms_key.arn
#   }
#   configuration_info {
#     arn      = aws_msk_configuration.kafka_config.arn
#     revision = aws_msk_configuration.kafka_config.latest_revision
#   }
#   open_monitoring {
#     prometheus {
#       jmx_exporter {
#         enabled_in_broker = true
#       }
#       node_exporter {
#         enabled_in_broker = true
#       }
#     }
#   }
#   logging_info {
#     broker_logs {
#       cloudwatch_logs {
#         enabled   = true
#         log_group = aws_cloudwatch_log_group.kafka_log_group.name
#       }
#     }
#   }
# }


# resource "aws_security_group" "kafka" {
#   name   = "${var.global_prefix}-kafka"
#   vpc_id = aws_vpc.fiap_lanches_vpc.id
#   ingress {
#     from_port   = 0
#     to_port     = 9092
#     protocol    = "TCP"
#     cidr_blocks = var.private_subnets_cidr
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
