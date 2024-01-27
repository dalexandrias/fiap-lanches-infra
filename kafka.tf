resource "aws_kms_key" "kafka_kms_key" {
  description = "fiaplanches123"
}

resource "aws_cloudwatch_log_group" "kafka_log_group" {
  name = "kafka_broker_logs"
}

resource "aws_msk_configuration" "kafka_config" {
  kafka_versions    = ["3.4.0"]
  name              = "${var.app_name}-config"
  server_properties = <<EOF
auto.create.topics.enable = true
delete.topic.enable = true
EOF
}

resource "aws_msk_cluster" "kafka" {
  cluster_name           = "${var.app_name}-kafka"
  kafka_version          = "3.5.1"
  number_of_broker_nodes = length(data.aws_availability_zones.available.names)
  broker_node_group_info {
    instance_type = "kafka.t3.small" # default value
    storage_info {
      ebs_storage_info {
        volume_size = 100
      }
    }
    client_subnets  = aws_subnet.private.*.id
    security_groups = [aws_security_group.kafka_security_group.id]
  }
  encryption_info {
    encryption_in_transit {
      client_broker = "PLAINTEXT"
    }
    encryption_at_rest_kms_key_arn = aws_kms_key.kafka_kms_key.arn
  }
  configuration_info {
    arn      = aws_msk_configuration.kafka_config.arn
    revision = aws_msk_configuration.kafka_config.latest_revision
  }
  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }
  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.kafka_log_group.name
      }
    }
  }
}
