# logs.tf

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "fiap_lanches_conta_log_group" {
  name              = "/ecs/${var.container_conta_name}"
  retention_in_days = 30

  tags = {
    Name = "${var.container_conta_name}-log-group"
  }
}

resource "aws_cloudwatch_log_group" "fiap_lanches_product_log_group" {
  name              = "/ecs/${var.container_product_name}"
  retention_in_days = 30

  tags = {
    Name = "${var.container_product_name}-log-group"
  }
}

resource "aws_cloudwatch_log_group" "fiap_lanches_order_log_group" {
  name              = "/ecs/${var.container_order_name}"
  retention_in_days = 30

  tags = {
    Name = "${var.container_order_name}-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "fiap_lanches_conta_log_stream" {
  name           = "${var.app_name}-log-stream"
  log_group_name = aws_cloudwatch_log_group.fiap_lanches_conta_log_group.name
}

