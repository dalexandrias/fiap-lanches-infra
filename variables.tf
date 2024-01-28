# variables.tf

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "app_name" {
  default = "fiap-lanches"
  type    = string
}

variable "container_conta_name" {
  default = "conta-app"
  type    = string
}

variable "container_product_name" {
  default = "product-app"
  type    = string
}

variable "container_order_name" {
  default = "order-app"
  type    = string
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "myEcsTaskExecutionRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "dict_app_image" {
  description = "Docker image to run in the ECS cluster"
  default = {
    conta   = "516194196157.dkr.ecr.us-east-1.amazonaws.com/fiap-lanches-conta:latest",
    product = "516194196157.dkr.ecr.us-east-1.amazonaws.com/fiap-lanches-product:latest",
    order   = "516194196157.dkr.ecr.us-east-1.amazonaws.com/fiap-lanches-order:latest"
  }
  type = map(string)
}

variable "dict_port_app" {
  description = "Port exposed by the docker image to redirect traffic to"
  default = {
    conta   = 8085,
    product = 8082,
    order   = 8081
  }
  type = map(number)
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "health_check_path" {
  default = "/actuator/health"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "512"
  type        = number
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "1024"
  type        = number
}

