resource "aws_lb" "transit_3" {
  name               = "transit3"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.transit_3_alb.id]
  subnets            = [aws_subnet.transit3_nat_alb_1.id, aws_subnet.transit3_nat_alb_2.id]
}

resource "aws_lb_listener" "transit_3" {
  load_balancer_arn = aws_lb.transit_3.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "transit_3" {
  name        = "transit3-alb"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.transit_3.id

  /*health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }*/
}

resource "aws_lb_listener_rule" "transit_3" {
  listener_arn = aws_lb_listener.transit_3.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.transit_3.arn
  }
}

resource "aws_lb_target_group_attachment" "transit_3_1" {
  target_group_arn  = aws_lb_target_group.transit_3.arn
  target_id         = "10.0.0.14"
  port              = 80
  availability_zone = "all"
}

resource "aws_lb_target_group_attachment" "transit_3_2" {
  target_group_arn  = aws_lb_target_group.transit_3.arn
  target_id         = "10.0.16.14"
  port              = 80
  availability_zone = "all"
}

resource "aws_lb_target_group_attachment" "transit_3_3" {
  target_group_arn  = aws_lb_target_group.transit_3.arn
  target_id         = "10.0.32.14"
  port              = 80
  availability_zone = "all"
}

resource "aws_security_group" "transit_3_alb" {
  name   = "transit3-alb"
  vpc_id = aws_vpc.transit_3.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "transit3-alb"
  }
}
