#set AWS security group for the Load balancer
resource "aws_security_group" "elb" {
  name_prefix = "elb-"
  vpc_id      = var.vpc_id

  ingress {
    from_port = var.elb_port
    to_port   = var.elb_port
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
}
#set lisstener
resource "aws_elb" "main" {
  name               = var.elb_name
  subnets            = var.subnets
  security_groups    = [aws_security_group.elb.id]
  listener {
    instance_port     = var.instance_port
    instance_protocol = "http"
    lb_port           = var.elb_port
    lb_protocol       = "http"
  }
}
#set LB domain name
output "elb_dns_name" {
  value = aws_elb.main.dns_name
}
