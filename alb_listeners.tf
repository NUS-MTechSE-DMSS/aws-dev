resource "aws_lb_listener_rule" "food" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.food.arn
  }

  condition {
    path_pattern {
      values = ["/food/*"]
    }
  }
}

resource "aws_lb_listener_rule" "preference" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.preference.arn
  }

  condition {
    path_pattern {
      values = ["/preference/*"]
    }
  }
}

resource "aws_lb_listener_rule" "user" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 5

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.user.arn
  }

  condition {
    path_pattern {
      values = ["/user/*"]
    }
  }
}
