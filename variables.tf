variable "app_name" {
  default = "fiap-lanches"
  type    = string
}

variable "ecr_regitry_url" {
  default = "516194196157.dkr.ecr.us-east-1.amazonaws.com/fiap-lanches:latest"
  type    = string
}

variable "region" {
  default = "us-east-1"
}

variable "environment" {
  description = "Deployment Environment"
  default     = "develop"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the vpc"
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "CIDR block for Public Subnet"
  default     = ["10.0.1.0/24"]
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "CIDR block for Private Subnet"
  default     = ["10.0.10.0/24"]
}
