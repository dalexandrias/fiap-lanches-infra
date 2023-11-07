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
  name = "${var.environment}-ecs-cluster"
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "${var.environment}-ecs-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 3
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
  }
}

# Define the ECS task definition for the service
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family             = "${var.app_name}-ecs-task"
  network_mode       = "awsvpc"
  execution_role_arn = "arn:aws:iam::516194196157:role/ecsTaskExecutionRole"
  cpu                = 256
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = jsonencode([
    {
      name      = "dockergs"
      image     = var.ecr_regitry_url
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# Define the ECS service that will run the task
resource "aws_ecs_service" "ecs_service" {
  name            = "${var.app_name}-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 2

  network_configuration {
    subnets         = [element(aws_subnet.subnet.*.id, 0), element(aws_subnet.subnet.*.id, 1)]
    security_groups = [aws_security_group.default.id]
  }

  force_new_deployment = true
  placement_constraints {
    type = "distinctInstance"
  }

  triggers = {
    redeployment = timestamp()
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "dockergs"
    container_port   = 80
  }

  depends_on = [aws_autoscaling_group.ecs_asg]
}
