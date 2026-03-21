resource "aws_lb_target_group" "food" {
  name        = "${var.name}-tg-food-${var.env}"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.this.id

  health_check {
    path     = "/food/actuator/health"
    matcher  = "200-399"
    interval = 30
  }
}

resource "aws_lb_target_group" "preference" {
  name        = "${var.name}-tg-preference-${var.env}"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.this.id

  health_check {
    path     = "/preference/actuator/health"
    matcher  = "200-399"
    interval = 30
  }
}

resource "aws_lb_target_group" "user" {
  name        = "${var.name}-tg-user-${var.env}"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.this.id

  health_check {
    path     = "/user/actuator/health"
    matcher  = "200-399"
    interval = 30
  }
}
