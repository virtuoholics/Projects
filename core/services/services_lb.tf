resource "aws_lb" "services" {
  name               = "services"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.services_alb.id]
  subnets            = [aws_subnet.eks_1.id, aws_subnet.eks_3.id]
}

resource "aws_lb_listener" "services" {
  load_balancer_arn = aws_lb.services.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.default.arn

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }

  depends_on = [
    aws_acm_certificate_validation.cert_validation
  ]
}

resource "aws_lb_listener_rule" "jenkins" {
  listener_arn = aws_lb_listener.services.arn
  priority     = 1

  condition {
    host_header {
      values = ["jenkins.${var.dns_common_name}"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }
}

resource "aws_lb_target_group" "jenkins" {
  name     = "jenkins"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.devsecops_project.id

  health_check {
    path                = "/"
    matcher             = 403 # It's a workaround. The default 200 "Ok" success code won't work because Jenkins requires authentication, failing which, ALB returns 403 "Access Forbidden".
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "jenkins" {
  target_group_arn = aws_lb_target_group.jenkins.arn
  target_id        = aws_instance.jenkins.id
  port             = 8080
}

resource "aws_lb_listener_rule" "rancher" {
  listener_arn = aws_lb_listener.services.arn
  priority     = 5

  condition {
    host_header {
      values = ["rancher.${var.dns_common_name}"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rancher.arn
  }
}

resource "aws_lb_target_group" "rancher" {
  name     = "rancher"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.devsecops_project.id

  health_check {
    path                = "/"
    protocol            = "HTTPS"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "rancher" {
  target_group_arn = aws_lb_target_group.rancher.arn
  target_id        = aws_instance.bastion.id
  port             = 443
}

resource "aws_lb_listener_rule" "pgAdmin" {
  listener_arn = aws_lb_listener.services.arn
  priority     = 11

  condition {
    host_header {
      values = ["pgadmin.${var.dns_common_name}"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pgAdmin.arn
  }
}

resource "aws_lb_target_group" "pgAdmin" {
  name     = "pgAdmin"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.devsecops_project.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "pgAdmin" {
  target_group_arn = aws_lb_target_group.pgAdmin.arn
  target_id        = aws_instance.bastion.id
  port             = 8000
}

resource "aws_lb_listener_rule" "vault" {
  listener_arn = aws_lb_listener.services.arn
  priority     = 12

  condition {
    host_header {
      values = ["vault.${var.dns_common_name}"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault.arn
  }
}

resource "aws_lb_target_group" "vault" {
  name     = "vault"
  port     = 51214
  protocol = "HTTPS"
  vpc_id   = aws_vpc.devsecops_project.id

  health_check {
    path                = "/ui/vault/"
    protocol            = "HTTPS"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "vault" {
  target_group_arn = aws_lb_target_group.vault.arn
  target_id        = aws_instance.bastion.id
  port             = 51214
}

resource "aws_lb_listener_rule" "nexus" {
  listener_arn = aws_lb_listener.services.arn
  priority     = 14

  condition {
    host_header {
      values = ["nexus.${var.dns_common_name}"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nexus.arn
  }
}

resource "aws_lb_target_group" "nexus" {
  name     = "nexus"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = aws_vpc.devsecops_project.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "nexus" {
  target_group_arn = aws_lb_target_group.nexus.arn
  target_id        = aws_instance.nexus.id
  port             = 8081
}

resource "aws_lb_listener_rule" "sonarqube" {
  listener_arn = aws_lb_listener.services.arn
  priority     = 17

  condition {
    host_header {
      values = ["sonarqube.${var.dns_common_name}"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sonarqube.arn
  }
}

resource "aws_lb_target_group" "sonarqube" {
  name     = "sonarqube"
  port     = 9000
  protocol = "HTTP"
  vpc_id   = aws_vpc.devsecops_project.id

  health_check {
    path                = "/sessions"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "sonarqube" {
  target_group_arn = aws_lb_target_group.sonarqube.arn
  target_id        = aws_instance.sonar.id
  port             = 9000
}

resource "aws_security_group" "services_alb" {
  name   = "services-alb"
  vpc_id = aws_vpc.devsecops_project.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "services-alb"
  }
}
