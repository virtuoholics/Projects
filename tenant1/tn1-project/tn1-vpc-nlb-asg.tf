resource "aws_launch_configuration" "tenant1-asg" {
  name            = "tenant1-asg"
  image_id        = "ami-085284d24fe829cd0"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.tenant1-asg.id]

  user_data = <<-EOF
        #!/bin/bash
        echo "Hello, World from $(hostname -f) - tenant1-VPC" >> index.html
        nohup busybox httpd -f -p 8080 &
        EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "tenant1-asg" {
  name = aws_launch_configuration.tenant1-asg.name

  launch_configuration = aws_launch_configuration.tenant1-asg.name
  vpc_zone_identifier  = [aws_subnet.tenant1-nlb-subnet.id]

  target_group_arns = [aws_lb_target_group.tenant1-nlb.arn]
  health_check_type = "ELB"

  min_size         = 1
  max_size         = 1
  min_elb_capacity = 1

  tag {
    key                 = "Name"
    value               = "tenant1-asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "tenant1-asg" {
  name   = "tenant1-asg"
  vpc_id = aws_vpc.tenant1.id

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name = "tenant1-asg"
  }
}

resource "aws_lb" "tenant1-nlb" {
  name               = "tenant1-nlb"
  load_balancer_type = "network"
  internal           = true

  subnet_mapping {
    subnet_id            = aws_subnet.tenant1-nlb-subnet.id
    private_ipv4_address = "10.5.0.5"
  }
}

resource "aws_lb_listener" "tenant1-nlb" {
  load_balancer_arn = aws_lb.tenant1-nlb.arn
  port              = 8080
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tenant1-nlb.arn
  }
}

resource "aws_lb_target_group" "tenant1-nlb" {
  name     = "tenant1-nlb"
  port     = 8080
  protocol = "TCP"
  vpc_id   = aws_vpc.tenant1.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 6
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
