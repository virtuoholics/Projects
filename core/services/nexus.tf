resource "aws_instance" "nexus" {
  ami                    = "ami-0aa2b7722dc1b5612" # Ubuntu 20.04 LTS us-east-1
  instance_type          = "m5.xlarge"
  vpc_security_group_ids = [aws_security_group.nexus.id]
  subnet_id              = aws_subnet.eks_1.id
  key_name               = data.aws_key_pair.instances[2].key_name
  iam_instance_profile   = aws_iam_instance_profile.instances.name

  root_block_device {
    volume_size = 30
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install unzip -y

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install

    sudo apt install git -y

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    sudo apt install openjdk-8-jdk -y
    wget https://download.sonatype.com/nexus/3/nexus-3.35.0-02-unix.tar.gz
    sudo tar -xvzf nexus-3.35.0-02-unix.tar.gz -C /opt/

    mkdir /mnt/efs
    mkdir /mnt/efs/nexus-data
    sudo chmod 777 /mnt/efs/nexus-data
    sudo chown 777 /mnt/efs/nexus-data

    sudo dnf install nfs-utils -y
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${aws_efs_file_system.instances.dns_name}:/ /mnt/efs/nexus-data

    cat >/etc/fstab <<EOT
      ${aws_efs_file_system.instances.dns_name}:/ /mnt/efs/nexus-data nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0
    EOT

    sudo /opt/nexus-3.35.0-02/bin/nexus start
EOF

  tags = {
    Name = "nexus"
  }

  depends_on = [
    aws_efs_mount_target.instances
  ]
}

resource "aws_security_group" "nexus" {
  name   = "nexus"
  vpc_id = aws_vpc.devsecops_project.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Nexus"
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    security_groups = [aws_security_group.services_alb.id]
  }

  ingress {
    from_port   = "-1"
    to_port     = "-1"
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nexus"
  }
}
