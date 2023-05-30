resource "aws_instance" "sonar" {
  ami                    = "ami-024e6efaf93d85776" # Ubuntu 22.04 LTS us-east-2
  instance_type          = "m5.xlarge"
  vpc_security_group_ids = [aws_security_group.sonar.id]
  subnet_id              = aws_subnet.eks_1.id
  key_name               = data.aws_key_pair.instances[3].key_name
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
    
    sudo apt install -y openjdk-17-jdk
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
    wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add - -y
    sudo apt install postgresql postgresql-contrib -y
    sudo systemctl start postgresql.service
    sudo systemctl enable postgresql.service

    # AFTER INTIAL BOOT, FOLLOW THIS GUIDE FOR POSTGRESQL CONFIG:
    # https://www.vultr.com/docs/install-sonarqube-on-ubuntu-20-04-lts/

    # AND THIS GUIDE FOR THE REMAINING SONARQUBE CONFIG:
    # https://snappytux.com/install-sonarqube-in-ubuntu/ (IT'S FOR VERSION 9.9.0.65466 BUT WILL ALSO WORK WITH 10.0.0.68432)

    
    sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.0.65466.zip
    sudo unzip sonarqube-9.9.0.65466.zip
    sudo mv sonarqube-9.9.0.65466 /opt/sonarqube
    sudo useradd -b /opt/sonarqube -s /bin/bash sonarqube
    sudo chown -R sonarqube:sonarqube /opt/sonarqube

    mkdir /mnt/efs
    mkdir /mnt/efs/sonar-data
    sudo chmod 777 /mnt/efs/sonar-data
    sudo chown 777 /mnt/efs/sonar-data

    sudo apt install nfs-common -y
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${aws_efs_file_system.instances.dns_name}:/ /mnt/efs/sonar-data

    cat >/etc/fstab <<EOT
      ${aws_efs_file_system.instances.dns_name}:/ /mnt/efs/sonar-data nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0
    EOT
EOF

  tags = {
    Name = "sonar"
  }

  depends_on = [
    aws_efs_mount_target.instances
  ]
}

resource "aws_security_group" "sonar" {
  name   = "sonar"
  vpc_id = aws_vpc.devsecops_project.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "SonarQube"
    from_port       = 9000
    to_port         = 9000
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
    Name = "sonar"
  }
}
