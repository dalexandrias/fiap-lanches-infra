resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "ecs-template"
  image_id      = "ami-04215982dedb895b4"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.default.id]
  iam_instance_profile {
    name = "ecsInstanceRole"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.app_name}-ecs-instance"
    }
  }

  # user_data = filebase64("${path.module}/ecs.sh")
}

resource "aws_autoscaling_group" "ecs_asg" {
  vpc_zone_identifier = [element(aws_subnet.subnet.*.id, 0)]
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

//Alb
resource "aws_lb" "ecs_alb" {
  name               = "${var.environment}-ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.default.id]
  subnets            = [element(aws_subnet.subnet.*.id, 0), element(aws_subnet.subnet2.*.id, 0)]

  tags = {
    Name = "${var.app_name}-ecs-alb"
  }
}

resource "aws_lb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 3000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

resource "aws_lb_target_group" "ecs_tg" {
  name        = "${var.environment}-ecs-target-group"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "90"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "20"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

# resource "aws_lb_target_group_attachment" "develop-alb-target-group" {

#   target_group_arn = aws_lb_target_group.ecs_tg.arn
#   target_id        = aws_launch_template.ecs_lt.id
#   port             = 8080
# }
