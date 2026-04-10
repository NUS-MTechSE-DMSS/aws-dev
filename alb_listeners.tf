resource "aws_lb_listener_rule" "food" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 10

  action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.this.arn
      user_pool_client_id = aws_cognito_user_pool_client.web.id
      user_pool_domain    = aws_cognito_user_pool_domain.this.domain

      session_cookie_name = "AWSELBAuthSessionCookie"
      session_timeout     = 36000

      on_unauthenticated_request = "allow"
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.food.arn
  }

  condition {
    path_pattern {
      values = ["/food*"]
    }
  }
}

resource "aws_lb_listener_rule" "preference" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 20

  action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.this.arn
      user_pool_client_id = aws_cognito_user_pool_client.web.id
      user_pool_domain    = aws_cognito_user_pool_domain.this.domain

      session_cookie_name = "AWSELBAuthSessionCookie"
      session_timeout     = 36000

      on_unauthenticated_request = "allow"
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.preference.arn
  }

  condition {
    path_pattern {
      values = ["/preference*"]
    }
  }
}

resource "aws_lb_listener_rule" "user" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 5

  action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.this.arn
      user_pool_client_id = aws_cognito_user_pool_client.web.id
      user_pool_domain    = aws_cognito_user_pool_domain.this.domain

      session_cookie_name = "AWSELBAuthSessionCookie"
      session_timeout     = 36000

      on_unauthenticated_request = "allow"
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.user.arn
  }

  condition {
    path_pattern {
      values = ["/user*"]
    }
  }
}

resource "aws_lb_listener_rule" "llm" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 30

  action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.this.arn
      user_pool_client_id = aws_cognito_user_pool_client.web.id
      user_pool_domain    = aws_cognito_user_pool_domain.this.domain

      session_cookie_name        = "AWSELBAuthSessionCookie"
      session_timeout            = 36000
      on_unauthenticated_request = "allow"
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.llm.arn
  }

  condition {
    path_pattern {
      values = ["/llm*"]
    }
  }
}
