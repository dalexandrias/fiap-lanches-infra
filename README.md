# Terraform AWS Infrastructure Repository

This repository contains Terraform configurations for provisioning a robust AWS infrastructure, including four load balancers, a Kafka cluster, MongoDB, RDS Postgres, and an ECS cluster using Fargate.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Provisioned Resources](#provisioned-resources)
- [Output Variables](#output-variables)
- [Contributing](#contributing)
- [License](#license)

## Overview

The infrastructure is designed to support a high-traffic application with a focus on scalability, reliability, and security. The following components are included:

- Four Application Load Balancers (ALBs) named "Product", "Client", "Kitchen", and "Order".
- A Kafka cluster for event streaming.
- A MongoDB instance for NoSQL database needs.
- An RDS Postgres instance for relational database requirements.
- An ECS cluster using Fargate for container orchestration.
- VPCs, subnets, security groups, and other networking resources to ensure proper network segmentation and security.

## Prerequisites

- Terraform installed on your local machine.
- AWS CLI configured with appropriate credentials and default region.
- An existing VPC and subnets in your AWS account (optional, as this repository includes network setup).

## Getting Started

1. Clone this repository to your local machine.
2. Navigate to each directory and initialize Terraform by running `terraform init`.
3. Create a Terraform variables file (`terraform.tfvars`) in each directory with the required variables.
4. Run `terraform plan` to view the proposed changes.
5. Run `terraform apply` to apply the changes.

## Provisioned Resources

- Load Balancers: Four ALBs to distribute traffic across the application's services.
- Kafka Cluster: A scalable and durable Kafka cluster for real-time data processing.
- MongoDB: A highly available MongoDB instance.
- RDS Postgres: A managed PostgreSQL database service.
- ECS Fargate: A serverless container management service.
- Networking: VPCs, subnets, security groups, and route tables for network configuration.

## Output Variables

The Terraform configurations will output the following endpoints upon successful deployment:

- `kafka_endpoint`: The endpoint for the Kafka cluster.
- `mongodb_endpoint`: The endpoint for the MongoDB instance.
- `rds_endpoint`: The endpoint for the RDS Postgres instance.
- `load_balancer_endpoints`: A map containing the endpoints for each load balancer.

## Contributing

We welcome contributions to this repository. Please submit a pull request with your proposed changes.

## License

This repository is licensed under the MIT License. See the `LICENSE` file for more information.
