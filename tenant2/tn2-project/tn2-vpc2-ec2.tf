resource "aws_instance" "tenant2-vpc2-ec2" {
  ami                         = "ami-052efd3df9dad4825"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.tenant2-vpc2-ec2.id]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.tenant2-vpc2-ec2-subnet.id

  tags = {
    Name = "tn2-vpc2-ec2"
  }
}

resource "aws_security_group" "tenant2-vpc2-ec2" {
  name   = "tn2-vpc2-ec2"
  vpc_id = aws_vpc.tenant2-vpc2.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tn2-vpc2-ec2"
  }
}
