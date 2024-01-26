# resource "aws_launch_template" "ecs_lt" {
#   name_prefix   = "ecs-template"
#   image_id      = "ami-04215982dedb895b4"
#   instance_type = "t2.micro"

#   vpc_security_group_ids = [aws_security_group.ecs_segurity_group.id]
#   iam_instance_profile {
#     name = "ecsInstanceRole"
#   }

#   block_device_mappings {
#     device_name = "/dev/xvda"
#     ebs {
#       volume_size = 30
#       volume_type = "gp2"
#     }
#   }

#   tag_specifications {
#     resource_type = "instance"
#     tags = {
#       Name = "${var.app_name}-ecs-instance"
#     }
#   }
# }
