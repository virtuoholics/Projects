resource "aws_lb" "winserver_asg" {
  name               = "winserver-asg"
  load_balancer_type = "network"
  subnets            = [for s in var.subnets : s]
}

resource "aws_lb_listener" "winserver_nlb_8443" {
  load_balancer_arn = aws_lb.winserver_asg.arn
  port              = 443
  protocol          = "TLS"
  certificate_arn   = var.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.winserver_nlb_8443.arn
  }
}

resource "aws_lb_listener" "winserver_nlb_8080" {
  load_balancer_arn = aws_lb.winserver_asg.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.winserver_nlb_8080.arn
  }
}

resource "aws_lb_target_group" "winserver_nlb_8443" {
  name     = "winserver-tg-8443"
  port     = 8443
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTPS"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 6
  }
}

resource "aws_lb_target_group" "winserver_nlb_8080" {
  name     = "winserver-tg-8080"
  port     = 8080
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 6
  }
}


/*resource "aws_lb" "winserver_asg" {
  name               = "winserver-asg"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.winserver_alb.id]
  subnets            = [for s in aws_subnet.public : s.id]
}

resource "aws_lb_listener" "winserver_alb" {
  load_balancer_arn = aws_lb.winserver_asg.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.winserver_alb.arn
  }
}

resource "aws_lb_target_group" "winserver_alb" {
  name     = "winserver-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.winserver_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-499"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_security_group" "winserver_alb" {
  name   = "winserver-alb"
  vpc_id = aws_vpc.winserver_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "winserver-alb"
  }
}

resource "aws_security_group_rule" "allow_http_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.winserver_alb.id

  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.winserver_win_server.id
}*/
