resource "aws_lb" "fiap_lanches_alb" {
  name               = "${var.app_name}-ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_segurity_group.id]
  subnets            = [element(aws_subnet.public_subnet_1.*.id, 0), element(aws_subnet.public_subnet_2.*.id, 0)]

  tags = {
    Name = "${var.app_name}-ecs-alb"
  }
}

resource "aws_security_group" "alb_segurity_group" {
  name        = "${var.app_name}-alb-default-sg"
  description = "Default SG to alllow traffic from the VPC"
  vpc_id      = aws_vpc.fiap_lanches_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_lb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.fiap_lanches_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fiap_lanches_tg.arn
  }
}

resource "aws_lb_target_group" "fiap_lanches_tg" {
  name        = "${var.app_name}-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.fiap_lanches_vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "90"
    protocol            = "HTTP"
    matcher             = "200-499"
    timeout             = "30"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

