# alb.tf

#-----------------------------------------------------------
# Fiap-lanches-Conta-api
#-----------------------------------------------------------
resource "aws_alb" "alb_conta_app" {
  name            = "${var.container_conta_name}-load-balancer"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_alb_target_group" "conta_app" {
  name        = "${var.container_conta_name}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "conta_app" {
  load_balancer_arn = aws_alb.alb_conta_app.id
  port              = var.dict_port_app["conta"]
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.conta_app.id
    type             = "forward"
  }
}

#-----------------------------------------------------------
# Fiap-lanches-Product-api
#-----------------------------------------------------------
resource "aws_alb" "alb_product_app" {
  name            = "${var.container_product_name}-load-balancer"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_alb_target_group" "product_app" {
  name        = "${var.container_product_name}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "product_app" {
  load_balancer_arn = aws_alb.alb_product_app.id
  port              = var.dict_port_app["product"]
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.product_app.id
    type             = "forward"
  }
}

#-----------------------------------------------------------
# Fiap-lanches-Order-api
#-----------------------------------------------------------
# resource "aws_alb" "alb_order_app" {
#   name            = "${var.container_order_name}-load-balancer"
#   subnets         = aws_subnet.public.*.id
#   security_groups = [aws_security_group.lb.id]
# }

# resource "aws_alb_target_group" "order_app" {
#   name        = "${var.container_order_name}-target-group"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = aws_vpc.main.id
#   target_type = "ip"

#   health_check {
#     healthy_threshold   = "3"
#     interval            = "30"
#     protocol            = "HTTP"
#     matcher             = "200"
#     timeout             = "3"
#     path                = var.health_check_path
#     unhealthy_threshold = "2"
#   }
# }

# resource "aws_alb_listener" "order_app" {
#   load_balancer_arn = aws_alb.alb_order_app.id
#   port              = var.dict_port_app["order"]
#   protocol          = "HTTP"

#   default_action {
#     target_group_arn = aws_alb_target_group.order_app.id
#     type             = "forward"
#   }
# }

