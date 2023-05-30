resource "aws_instance" "bastion" {
  ami                    = "ami-0aa2b7722dc1b5612" # Ubuntu 20.04 LTS us-east-1
  instance_type          = "m5.xlarge"
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id              = aws_subnet.eks_1.id
  key_name               = data.aws_key_pair.instances[0].key_name
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
    
    curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg
    sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
    #### INSTALLATION FOR ONLY PGADMIN4-WEB
    sudo apt install pgadmin4-web -y
    #### CONFIGURE THE WEBSERVER FOR PGADMIN4-WEB FROM INSIDE THE INSTANCE
    #sudo /usr/pgadmin4/bin/setup-web.sh
    ### DB CLUSTER ENDPOINT TO CONNECT FROM PGADMIN
    ### customer-otc.cluster-xxxxxxxxxxxx.us-east-1.rds.amazonaws.com
    
    sudo apt-get update
    sudo apt-get install -y unzip
    # Download and install Vault
    #VAULT_VERSION="1.7.3"
    wget https://releases.hashicorp.com/vault/1.7.3/vault_1.7.3_linux_amd64.zip
    unzip vault_1.7.3_linux_amd64.zip
    mv vault /usr/bin
    sudo chmod 755 /usr/bin/
    # Create Vault configuration file
    sudo mkdir /etc/vault
    sudo chmod 755 /etc/vault
    
    sudo cat <<CFG > /etc/vault/config.hcl
    disable_cache = true
    disable_mlock = true
    
    ui = true
    
    listener "tcp" {
      address     = "$(curl http://169.254.169.254/latest/meta-data/public-hostname):51214"
      tls_disable      = 0
      tls_cert_file = "/etc/ssl/certs/vault.crt"
      tls_key_file = "/etc/ssl/private/vault.key"
    }
    
    storage "file" {
      path = "/var/lib/vault/data"
    }
    CFG

    # Start Vault server
    sudo mkdir -p /var/lib/vault/data

    sudo cat <<UNIT > /etc/systemd/system/vault.service
    [Unit]
    Description=Vault server
    Requires=network-online.target
    After=network-online.target
    ConditionFileNotEmpty=/etc/vault/config.hcl
    
    [Service]
    ProtectSystem=full
    ProtectHome=read-only
    PrivateTmp=yes
    PrivateDevices=yes
    SecureBits=keep-caps
    AmbientCapabilities=CAP_IPC_LOCK
    NoNewPrivileges=yes
    ExecStart=/usr/bin/vault server -config=/etc/vault/config.hcl
    ExecReload=/bin/kill --signal HUP
    KillMode=process
    KillSignal=SIGINT
    Restart=on-failure
    RestartSec=5
    TimeoutStopSec=30
    StartLimitBurst=3
    LimitNOFILE=65536
    [Install]
    WantedBy=multi-user.target
    UNIT
    
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vault.key -out /etc/ssl/certs/vault.crt -subj "/CN=ec2-44-213-140-190.compute-1.amazonaws.com" -addext "subjectAltName = DNS:ec2-44-213-140-190.compute-1.amazonaws.com"
    export VAULT_ADDR="https://$(curl http://169.254.169.254/latest/meta-data/public-hostname):51214"
    sudo systemctl daemon-reload
    sudo systemctl start vault.service
    sudo systemctl enable vault.service
    
    # THE BELOW COMMAND HAS TO BE ENTERED AFTER TAKING THE TOKEN FROM VAULT CREDENTIALS FILE AFTER INITIAL ACCESS:
    # export VAULT_TOKEN="s.YJI513A28r0lHtLb9pqXA03h"
    
    mkdir /mnt/efs
    mkdir /mnt/efs/bastion-data
    sudo chmod 777 /mnt/efs/bastion-data
    sudo chown 777 /mnt/efs/bastion-data
    sudo apt install nfs-common -y
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${aws_efs_file_system.instances.dns_name}:/ /mnt/efs/bastion-data
    cat >/etc/fstab <<EOT
      ${aws_efs_file_system.instances.dns_name}:/ /mnt/efs/bastion-data nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0
    EOT
    
    sudo apt install apt-transport-https curl gnupg-agent ca-certificates software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    sudo apt install docker-ce docker-ce-cli containerd.io -y
    sudo systemctl enable docker
    sudo usermod -aG docker ubuntu
    sudo reboot
EOF

  tags = {
    Name = "bastion"
  }

  depends_on = [
    aws_efs_mount_target.instances
  ]
}

resource "aws_security_group" "bastion" {
  name   = "bastion"
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
    description     = "Vault"
    from_port       = 51214
    to_port         = 51214
    protocol        = "tcp"
    security_groups = [aws_security_group.services_alb.id]
  }

  ingress {
    description     = "pgAdmin4"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.services_alb.id]
  }

  ingress {
    description     = "Rancher"
    from_port       = 443
    to_port         = 443
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
    Name = "bastion"
  }
}
