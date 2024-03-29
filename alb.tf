# alb.tf

resource "aws_alb" "main" {
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

resource "aws_alb_listener" "conta_app" {
  load_balancer_arn = aws_alb.main.id
  port              = var.dict_port_app["conta"]
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.conta_app.id
    type             = "forward"
  }
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
  load_balancer_arn = aws_alb.main.id
  port              = var.dict_port_app["product"]
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.product_app.id
    type             = "forward"
  }
}

resource "aws_alb_target_group" "order_app" {
  name        = "${var.container_order_name}-target-group"
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

resource "aws_alb_listener" "order_app" {
  load_balancer_arn = aws_alb.main.id
  port              = var.dict_port_app["order"]
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.order_app.id
    type             = "forward"
  }
}

resource "aws_alb_target_group" "kitchen_app" {
  name        = "${var.container_kitchen_name}-target-group"
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

resource "aws_alb_listener" "kitchen_app" {
  load_balancer_arn = aws_alb.main.id
  port              = var.dict_port_app["kitchen"]
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.kitchen_app.id
    type             = "forward"
  }
}
