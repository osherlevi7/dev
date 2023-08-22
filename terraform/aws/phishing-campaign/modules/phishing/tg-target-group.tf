resource "aws_alb_target_group" "test" {
  name     = "phishing-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-abc12345"

  health_check {
    enabled = true
    path    = "/"
    port    = "traffic-port"
  }
}

resource "aws_alb_target_group_attachment" "test" {
  target_group_arn = aws_alb_target_group.test.arn
  target_id        = aws_instance.phishing_server.id
  port             = 80
}
