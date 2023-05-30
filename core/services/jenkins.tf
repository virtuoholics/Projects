resource "aws_instance" "jenkins" {
  ami                    = "ami-024e6efaf93d85776" # Ubuntu 22.04 LTS us-east-2
  instance_type          = "m5.xlarge"
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  subnet_id              = aws_subnet.eks_1.id
  key_name               = data.aws_key_pair.instances[1].key_name
  iam_instance_profile   = aws_iam_instance_profile.instances.name

  root_block_device {
    volume_size = 30
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install openjdk-17-jdk openjdk-17-jre -y

    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]  https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt update
    sudo apt install jenkins -y
    sudo systemctl start jenkins.service
    sudo systemctl enable jenkins.service

    sudo apt install unzip -y
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install

    sudo apt install git -y

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    sudo apt install  software-properties-common gnupg2 curl -y
    curl https://apt.releases.hashicorp.com/gpg | gpg --dearmor > hashicorp.gpg
    sudo install -o root -g root -m 644 hashicorp.gpg /etc/apt/trusted.gpg.d/
    sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" -y
    sudo apt install terraform

    sudo apt-get install wget apt-transport-https gnupg lsb-release -y
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
    echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
    sudo apt-get update
    sudo apt-get install trivy

    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt update
    sudo apt install python3.11 -y
    sudo ln -s /usr/bin/python3 /usr/bin/python
    sudo apt-get -y install python3-boto3 -y

    mkdir /mnt/efs
    mkdir /mnt/efs/jenkins-data
    sudo chmod 777 /mnt/efs/jenkins-data
    sudo chown 777 /mnt/efs/jenkins-data
    sudo apt install nfs-common -y
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${aws_efs_file_system.instances.dns_name}:/ /mnt/efs/jenkins-data
    cat >/etc/fstab <<EOT
      ${aws_efs_file_system.instances.dns_name}:/ /mnt/efs/jenkins-data nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0
    EOT

    sudo apt install apt-transport-https curl gnupg-agent ca-certificates software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    sudo apt install docker-ce docker-ce-cli containerd.io -y
    sudo systemctl enable docker
    sudo usermod -aG docker jenkins
    sudo usermod -aG docker ubuntu
    sudo reboot
EOF

  tags = {
    Name = "jenkins"
  }

  depends_on = [
    aws_efs_mount_target.instances
  ]
}

resource "aws_security_group" "jenkins" {
  name   = "jenkins"
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
    description     = "Jenkins"
    from_port       = 8080
    to_port         = 8080
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
    Name = "jenkins"
  }
}
