provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "this" {
  ami                    = "ami-02f3416038bdb17fb" #Ubuntu Server 22.04 LTS (us-east-2)
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.this.id]
  subnet_id              = data.aws_subnets.default.ids[0]
  key_name               = data.aws_key_pair.default.key_name

  tags = {
    Name = "test_ansible_nginx_hello"
  }
}

resource "null_resource" "this" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.this.public_dns
      private_key = file("~/.ssh/kp-useast2-2.pem")
    }

    inline = ["echo 'connected!'"]
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -T 300 -i ${aws_instance.this.public_dns}, --user ubuntu --private-key ~/.ssh/kp-useast2-2.pem linux-app.yaml"
  }

  depends_on = [aws_instance.this]
}


resource "aws_security_group" "this" {
  name = "test_ansible_nginx_hello"

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
    Name = "test_ansible_nginx_hello"
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_key_pair" "default" {
  key_name           = "kp-useast2-2"
  include_public_key = true
}

output "public_dns" {
  value = aws_instance.this.public_dns
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

