# ecs.tf

resource "aws_ecs_cluster" "main" {
  name = "fiap-lanches-cluster"
}

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
      "image" : var.dict_app_image["conta"],
      "cpu" : var.fargate_cpu,
      "memory" : var.fargate_memory,
      "networkMode" : "awsvpc",
      "portMappings" : [
        {
          "containerPort" : var.dict_port_app["conta"],
          "hostPort" : var.dict_port_app["conta"],
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
          "name" : "SPRING_DATA_MONGODB_URI",
          "value" : "mongodb://${aws_docdb_cluster.document_db_cluster.master_username}:${aws_docdb_cluster.document_db_cluster.master_password}@${aws_docdb_cluster.document_db_cluster.endpoint}:${aws_docdb_cluster.document_db_cluster.port}/fiap-lanches-client?tls=false&replicaSet=rs&readPreference=secondaryPreferred&retryWrites=false"
        },
        {
          "name" : "SPRING_JPA_HIBERNATE_DDL_AUTO",
          "value" : "create"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/${var.container_conta_name}",
          "awslogs-region" : "${var.aws_region}",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
  depends_on = [aws_alb.main, aws_docdb_cluster.document_db_cluster, aws_docdb_cluster_instance.document_db_instance]
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
    target_group_arn = aws_alb_target_group.conta_app.id
    container_name   = var.container_conta_name
    container_port   = var.dict_port_app["conta"]
  }

  depends_on = [aws_alb_listener.conta_app, aws_iam_role_policy_attachment.ecs_task_execution_role, aws_alb.main, aws_db_instance.db_instance]
}

#-----------------------------------------------------------
# Fiap-lanches-Cozinha-api
#-----------------------------------------------------------
resource "aws_ecs_task_definition" "kitchen-task-app" {
  family                   = "${var.app_name}-kitchen-app-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions = jsonencode([
    {
      "name" : "${var.container_conta_name}",
      "image" : var.dict_app_image["kitchen"],
      "cpu" : var.fargate_cpu,
      "memory" : var.fargate_memory,
      "networkMode" : "awsvpc",
      "portMappings" : [
        {
          "containerPort" : var.dict_port_app["kitchen"],
          "hostPort" : var.dict_port_app["kitchen"],
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
          "name" : "SPRING_DATA_MONGODB_URI",
          "value" : "mongodb://${aws_docdb_cluster.document_db_cluster.master_username}:${aws_docdb_cluster.document_db_cluster.master_password}@${aws_docdb_cluster.document_db_cluster.endpoint}:${aws_docdb_cluster.document_db_cluster.port}/fiap-lanches-client"
        },
        {
          "name" : "SPRING_JPA_HIBERNATE_DDL_AUTO",
          "value" : "create"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/${var.container_kitchen_name}",
          "awslogs-region" : "${var.aws_region}",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
  depends_on = [aws_alb.main, aws_docdb_cluster.document_db_cluster, aws_docdb_cluster_instance.document_db_instance]
}

resource "aws_ecs_service" "kitchen-service-main" {
  name            = "${var.app_name}-kitchen-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.kitchen-task-app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.conta_app.id
    container_name   = var.container_conta_name
    container_port   = var.dict_port_app["kitchen"]
  }

  depends_on = [aws_alb_listener.conta_app, aws_iam_role_policy_attachment.ecs_task_execution_role, aws_alb.main, aws_db_instance.db_instance]
}

#-----------------------------------------------------------
# Fiap-lanches-Product-api
#-----------------------------------------------------------
resource "aws_ecs_task_definition" "product-task-app" {
  family                   = "${var.app_name}-product-app-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions = jsonencode([
    {
      "name" : "${var.container_product_name}",
      "image" : var.dict_app_image["product"],
      "cpu" : var.fargate_cpu,
      "memory" : var.fargate_memory,
      "networkMode" : "awsvpc",
      "portMappings" : [
        {
          "containerPort" : var.dict_port_app["product"],
          "hostPort" : var.dict_port_app["product"],
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
          "value" : "jdbc:postgresql://${aws_db_instance.db_instance.endpoint}/fiaplanches"
        },
        {
          "name" : "SPRING_JPA_HIBERNATE_DDL_AUTO",
          "value" : "create"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/${var.container_product_name}",
          "awslogs-region" : "${var.aws_region}",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
  depends_on = [aws_alb.main, aws_db_instance.db_instance]
}

resource "aws_ecs_service" "product-service-main" {
  name            = "${var.app_name}-product-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.product-task-app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.product_app.id
    container_name   = var.container_product_name
    container_port   = var.dict_port_app["product"]
  }

  depends_on = [aws_alb_listener.product_app, aws_iam_role_policy_attachment.ecs_task_execution_role, aws_alb.main, aws_db_instance.db_instance]
}

#-----------------------------------------------------------
# Fiap-lanches-Pagamento-api
#-----------------------------------------------------------
resource "aws_ecs_task_definition" "payment-task-app" {
  family                   = "${var.app_name}-payment-app-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions = jsonencode([
    {
      "name" : "${var.container_payment_name}",
      "image" : var.dict_app_image["payment"],
      "cpu" : var.fargate_cpu,
      "memory" : var.fargate_memory,
      "networkMode" : "awsvpc",
      "portMappings" : [
        {
          "containerPort" : var.dict_port_app["payment"],
          "hostPort" : var.dict_port_app["payment"],
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
          "value" : "jdbc:postgresql://${aws_db_instance.db_instance.endpoint}/fiaplanches"
        },
        {
          "name" : "SPRING_JPA_HIBERNATE_DDL_AUTO",
          "value" : "create"
        },
        {
          "name" : "SPRING_KAFKA_BOOTSTRAP_SERVERS",
          "value" : "${aws_msk_cluster.kafka.bootstrap_brokers}"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/${var.container_payment_name}",
          "awslogs-region" : "${var.aws_region}",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
  depends_on = [aws_msk_cluster.kafka, aws_db_instance.db_instance]
}

resource "aws_ecs_service" "payment-service-main" {
  name            = "${var.app_name}-payment-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.payment-task-app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role, aws_db_instance.db_instance, aws_msk_cluster.kafka]
}

#-----------------------------------------------------------
# Fiap-lanches-Order-api
#-----------------------------------------------------------
resource "aws_ecs_task_definition" "order-task-app" {
  family                   = "${var.app_name}-order-app-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  container_definitions = jsonencode([
    {
      "name" : "${var.container_order_name}",
      "image" : var.dict_app_image["order"],
      "cpu" : 1024,
      "memory" : 2048,
      "networkMode" : "awsvpc",
      "portMappings" : [
        {
          "containerPort" : var.dict_port_app["order"],
          "hostPort" : var.dict_port_app["order"],
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
          "value" : "jdbc:postgresql://${aws_db_instance.db_instance.endpoint}/fiaplanches"
        },
        {
          "name" : "SPRING_JPA_HIBERNATE_DDL_AUTO",
          "value" : "create"
        },
        {
          "name" : "SPRING_KAFKA_BOOTSTRAP_SERVERS",
          "value" : "${aws_msk_cluster.kafka.bootstrap_brokers}"
        },
        {
          "name" : "REST_CLIENTS_ENDPOINT",
          "value" : "http://${aws_alb.main.dns_name}:8085/v1/client"
        },
        {
          "name" : "REST_PRODUCTS_ENDPOINT",
          "value" : "http://${aws_alb.main.dns_name}:8082/v1/product"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/${var.container_order_name}",
          "awslogs-region" : "${var.aws_region}",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
  depends_on = [aws_alb.main, aws_msk_cluster.kafka, aws_db_instance.db_instance]
}

resource "aws_ecs_service" "order-service-main" {
  name            = "${var.app_name}-order-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.order-task-app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.order_app.id
    container_name   = var.container_order_name
    container_port   = var.dict_port_app["order"]
  }

  depends_on = [aws_alb_listener.conta_app, aws_iam_role_policy_attachment.ecs_task_execution_role, aws_alb.main, aws_msk_cluster.kafka, aws_db_instance.db_instance]
}
