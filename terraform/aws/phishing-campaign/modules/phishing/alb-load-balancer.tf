resource "aws_alb" "example" {
  name               = "phishing-alb-tg"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-abc12345"]
  subnets            = ["subnet-abc12345", "subnet-bcd23456"]

  tags = {
    Name = "PhishingALB"
  }
}
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.example.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.test.arn
  }
}