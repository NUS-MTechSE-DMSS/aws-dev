resource "aws_lb" "app" {
  name               = "${var.name}-alb-dev"
  load_balancer_type = "application"
  internal           = false

  subnets         = data.aws_subnets.default.ids
  security_groups = [aws_security_group.alb.id]

  enable_deletion_protection = false

  tags = {
    Name = "${var.name}-alb-dev"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "200"
    }
  }
}
