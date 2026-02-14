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

resource "aws_lb_target_group" "app" {
  name        = "${var.name}-tg-dev"
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id

  #   health_check {
  #     # todo enable when ecs done
  #     enabled  = true
  #     path     = var.health_check_path
  #     protocol = "HTTP"

  #     matcher             = "200-399"
  #     interval            = 30
  #     timeout             = 5
  #     healthy_threshold   = 2
  #     unhealthy_threshold = 2
  #   }

  tags = {
    Name = "${var.name}-tg-dev"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  #   default_action {
  #     type             = "forward"
  #     target_group_arn = aws_lb_target_group.app.arn
  #   }

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "dev alb up"
      status_code  = "200"
    }
  }
}