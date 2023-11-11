terraform {
  cloud {
    organization = "fiap-lanches-organization"

    workspaces {
      name = "fiap-lanches-workspace"
    }
  }
}

provider "aws" {
  region = var.region
}

# Create an ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.app_name}-ecs-cluster"
}

# Define the ECS task definition for the service
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "${var.app_name}-ecs-task"
  network_mode             = "awsvpc"
  execution_role_arn       = "arn:aws:iam::516194196157:role/ecsTaskExecutionRole"
  cpu                      = 512
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      "name" : "${var.app_name}-api",
      "image" : var.ecr_regitry_url,
      "cpu" : 512,
      "memory" : 1024,
      "portMappings" : [
        {
          "containerPort" : 8080,
          "hostPort" : 8080,
          "protocol" : "tcp"
        }
      ],
      "essential" : true,
      "environment" : [
        {
          "name" : "SPRING_DATASOURCE_USERNAME",
          "value" : "fiap_lanches"
        },
        {
          "name" : "WEBHOOK_URL",
          "value" : "http://172.31.20.230:8081"
        },
        {
          "name" : "SPRING_DATASOURCE_PASSWORD",
          "value" : "fiaplanches123"
        },
        {
          "name" : "SPRING_DATASOURCE_URL",
          "value" : "jdbc:postgresql://develop-rds-postgres.cf5bq2g9b2j1.us-east-1.rds.amazonaws.com:5432/fiaplanches"
        },
        {
          "name" : "SPRING_JPA_HIBERNATE_DDL_AUTO",
          "value" : "create"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/task-fiap-lanches",
          "awslogs-region" : "us-east-1",
          "awslogs-stream-prefix" : "ecs"
        },
        "secretOptions" : []
      }
    }
  ])
}

# Define the ECS service that will run the task
resource "aws_ecs_service" "ecs_service" {
  name             = "${var.app_name}-ecs-fargate"
  cluster          = aws_ecs_cluster.ecs_cluster.id
  task_definition  = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count    = 2
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    subnets          = [element(aws_subnet.public_subnet_2.*.id, 0), element(aws_subnet.public_subnet_1.*.id, 0)]
    security_groups  = [aws_security_group.ecs_segurity_group.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.fiap_lanches_tg.arn
    container_name   = "${var.app_name}-api"
    container_port   = 8080
  }

  depends_on = [aws_autoscaling_group.ecs_asg, aws_lb.fiap_lanches_alb]

  tags = {
    Environment = "${var.environment}"
    Application = "${var.app_name}"
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  vpc_zone_identifier = [element(aws_subnet.public_subnet_2.*.id, 0), element(aws_subnet.public_subnet_1.*.id, 0)]
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_security_group" "ecs_segurity_group" {
  name        = "${var.app_name}-ecs-default-sg"
  description = "Libera o trafego para o ECS"
  vpc_id      = aws_vpc.fiap_lanches_vpc.id

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.alb_segurity_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = "${var.environment}"
  }
}
