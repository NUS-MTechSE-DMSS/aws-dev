resource "aws_lb_listener_rule" "food" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.food.arn


    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.this.arn
      user_pool_client_id = aws_cognito_user_pool_client.this.id
      user_pool_domain    = aws_cognito_user_pool_domain.this.domain

      on_unauthenticated_request = "allow"
    }
  }

  condition {
    path_pattern {
      values = ["/food*"]
    }
  }
}

resource "aws_lb_listener_rule" "preference" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.preference.arn

    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.this.arn
      user_pool_client_id = aws_cognito_user_pool_client.this.id
      user_pool_domain    = aws_cognito_user_pool_domain.this.domain

      on_unauthenticated_request = "allow"
    }
  }

  condition {
    path_pattern {
      values = ["/preference*"]
    }
  }
}

resource "aws_lb_listener_rule" "user" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 5

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.user.arn

    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.this.arn
      user_pool_client_id = aws_cognito_user_pool_client.this.id
      user_pool_domain    = aws_cognito_user_pool_domain.this.domain

      on_unauthenticated_request = "allow"
    }
  }

  condition {
    path_pattern {
      values = ["/user*"]
    }
  }
}
