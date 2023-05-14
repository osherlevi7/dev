#set configuration for the instance group
resource "aws_launch_configuration" "main" {
  name_prefix = var.asg_name
  image_id    = var.ami_id
  instance_type = var.instance_type
  user_data = base64encode(local.asg_userdata)
  security_groups = [var.asg_security_group_id]
}
#set autoscaling group 
resource "aws_autoscaling_group" "main" {
  name_prefix = var.asg_name
  launch_configuration = aws_launch_configuration.main.name
  vpc_zone_identifier = var.subnets
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.desired_capacity
    #set tags
  tag {
    key = "Name"
    value = var.asg_name
    propagate_at_launch = true
  }

  tag {
    key = "Environment"
    value = var.environment
    propagate_at_launch = true
  }
}
#default application
locals {
  asg_userdata = <<EOF
#!/bin/bash
echo "Hello, World!" > index.html
nohup python -m SimpleHTTPServer 80 &
EOF
}

output "asg_name" {
  value = aws_autoscaling_group.main.name
}
