resource "aws_lb" "app" {
  name               = "${var.name}-alb-${var.env}"
  load_balancer_type = "application"
  internal           = false

  subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  security_groups = [aws_security_group.alb.id]

  enable_deletion_protection = false

  tags = {
    Name = "${var.name}-alb-${var.env}"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  certificate_arn = aws_acm_certificate.alb.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Bad Request"
      status_code  = "400"
    }
  }
}