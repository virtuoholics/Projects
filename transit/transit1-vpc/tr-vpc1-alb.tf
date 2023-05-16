resource "aws_lb" "transit_1" {
  name               = "transit1"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.transit_1_alb.id]
  subnets            = [aws_subnet.transit1_nat_alb_1.id, aws_subnet.transit1_nat_alb_2.id]
}

resource "aws_lb_listener" "transit_1" {
  load_balancer_arn = aws_lb.transit_1.arn
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

resource "aws_lb_target_group" "transit_1" {
  name        = "transit1-alb"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.transit_1.id

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

resource "aws_lb_listener_rule" "transit_1" {
  listener_arn = aws_lb_listener.transit_1.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.transit_1.arn
  }
}

resource "aws_lb_target_group_attachment" "transit_1_1" {
  target_group_arn  = aws_lb_target_group.transit_1.arn
  target_id         = "10.4.0.5"
  port              = 8080
  availability_zone = "all"
}

resource "aws_lb_target_group_attachment" "transit_1_2" {
  target_group_arn  = aws_lb_target_group.transit_1.arn
  target_id         = "10.5.0.5"
  port              = 8080
  availability_zone = "all"
}

resource "aws_security_group" "transit_1_alb" {
  name   = "transit1-alb"
  vpc_id = aws_vpc.transit_1.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.4.0.0/14"]
  }

  tags = {
    Name = "transit1-alb"
  }
}
