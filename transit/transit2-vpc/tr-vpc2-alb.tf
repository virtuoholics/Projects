resource "aws_lb" "transit_2" {
  name               = "transit2"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.transit_2_alb.id]
  subnets            = [aws_subnet.transit2_nat_alb_1.id, aws_subnet.transit2_nat_alb_2.id]
}

resource "aws_lb_listener" "transit_2" {
  load_balancer_arn = aws_lb.transit_2.arn
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

resource "aws_lb_target_group" "transit_2" {
  name        = "transit2-alb"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.transit_2.id

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

resource "aws_lb_listener_rule" "transit_2" {
  listener_arn = aws_lb_listener.transit_2.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.transit_2.arn
  }
}

resource "aws_lb_target_group_attachment" "transit_2_1" {
  target_group_arn  = aws_lb_target_group.transit_2.arn
  target_id         = "10.1.0.5"
  port              = 8080
  availability_zone = "all"
}

resource "aws_lb_target_group_attachment" "transit_2_2" {
  target_group_arn  = aws_lb_target_group.transit_2.arn
  target_id         = "10.3.0.5"
  port              = 8080
  availability_zone = "all"
}

resource "aws_security_group" "transit_2_alb" {
  name   = "transit2-alb"
  vpc_id = aws_vpc.transit_2.id

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
    cidr_blocks = ["10.0.0.0/14"]
  }

  tags = {
    Name = "transit2-alb"
  }
}
