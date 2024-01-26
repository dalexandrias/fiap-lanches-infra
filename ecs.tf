# ecs.tf

resource "aws_ecs_cluster" "main" {
  name = "fiap-lanches-cluster"
}

# data "template_file" "fiap_lanches_app" {
#   template = file("./templates/ecs/fiap_lanches_app.json.tpl")

#   vars = {
#     app_image      = var.app_image
#     app_port       = var.app_port
#     fargate_cpu    = var.fargate_cpu
#     fargate_memory = var.fargate_memory
#     aws_region     = var.aws_region
#   }
# }


#-----------------------------------------------------------
# Fiap-lanches-Conta-api
#-----------------------------------------------------------
resource "aws_ecs_task_definition" "conta-task-app" {
  family                   = "${var.app_name}-conta-app-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions = jsonencode([
    {
      "name" : "${var.container_conta_name}",
      "image" : var.app_image,
      "cpu" : var.fargate_cpu,
      "memory" : var.fargate_memory,
      "networkMode" : "awsvpc",
      "portMappings" : [
        {
          "containerPort" : var.app_port,
          "hostPort" : var.app_port,
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
          "name" : "SPRING_DATASOURCE_PASSWORD",
          "value" : "fiaplanches123"
        },
        {
          "name" : "SPRING_DATASOURCE_URL",
          "value" : "jdbc:postgresql://fiap-lanches-rds-postgres.cf5bq2g9b2j1.us-east-1.rds.amazonaws.com:5432/fiaplanches"
        },
        {
          "name" : "SPRING_JPA_HIBERNATE_DDL_AUTO",
          "value" : "create"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/${var.app_name}-conta-app",
          "awslogs-region" : "${var.aws_region}",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "conta-service-main" {
  name            = "${var.app_name}-conta-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.conta-task-app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = var.container_conta_name
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.conta_app, aws_iam_role_policy_attachment.ecs_task_execution_role]
}


#-----------------------------------------------------------
# Fiap-lanches-Product-api
#-----------------------------------------------------------
# resource "aws_ecs_task_definition" "product-task-app" {
#   family                   = "${var.app_name}-product-app-task"
#   execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = var.fargate_cpu
#   memory                   = var.fargate_memory
#   container_definitions = jsonencode([
#     {
#       "name" : "${var.container_product_name}",
#       "image" : var.app_image,
#       "cpu" : var.fargate_cpu,
#       "memory" : var.fargate_memory,
#       "networkMode" : "awsvpc",
#       "portMappings" : [
#         {
#           "containerPort" : var.app_port,
#           "hostPort" : var.app_port,
#           "protocol" : "tcp"
#         }
#       ],
#       "essential" : true,
#       "environment" : [
#         {
#           "name" : "SPRING_DATASOURCE_USERNAME",
#           "value" : "fiap_lanches"
#         },
#         {
#           "name" : "SPRING_DATASOURCE_PASSWORD",
#           "value" : "fiaplanches123"
#         },
#         {
#           "name" : "SPRING_DATASOURCE_URL",
#           "value" : "jdbc:postgresql://fiap-lanches-rds-postgres.cf5bq2g9b2j1.us-east-1.rds.amazonaws.com:5432/fiaplanches"
#         },
#         {
#           "name" : "SPRING_JPA_HIBERNATE_DDL_AUTO",
#           "value" : "create"
#         }
#       ],
#       "logConfiguration" : {
#         "logDriver" : "awslogs",
#         "options" : {
#           "awslogs-group" : "/ecs/${var.app_name}-conta-app",
#           "awslogs-region" : "${var.aws_region}",
#           "awslogs-stream-prefix" : "ecs"
#         }
#       }
#     }
#   ])
# }

# resource "aws_ecs_service" "product-service-main" {
#   name            = "${var.app_name}-product-service"
#   cluster         = aws_ecs_cluster.main.id
#   task_definition = aws_ecs_task_definition.product-task-app.arn
#   desired_count   = var.app_count
#   launch_type     = "FARGATE"

#   network_configuration {
#     security_groups  = [aws_security_group.ecs_tasks.id]
#     subnets          = aws_subnet.private.*.id
#     assign_public_ip = true
#   }

#   load_balancer {
#     target_group_arn = aws_alb_target_group.app.id
#     container_name   = var.container_product_name
#     container_port   = var.app_port
#   }

#   depends_on = [aws_alb_listener.conta_app, aws_iam_role_policy_attachment.ecs_task_execution_role]
# }
