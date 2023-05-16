resource "aws_instance" "bastion" {
  ami                    = "ami-064d05b4fe8515623" #  ami-012bb86d0081c5240 - Microsoft Windows Server 2022 Base (us-east-2)
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id              = var.subnet_id
  key_name               = var.keypair
  iam_instance_profile   = var.instance_profile

  user_data = <<-EOF
        <powershell>
        Enable-NetFirewallRule -Name *ICMP4*
        Enable-NetFirewallRule -Name *ssh*

        Install-WindowsFeature -Name GPMC,RSAT-AD-PowerShell,RSAT-AD-AdminCenter,RSAT-ADDS-Tools,RSAT-DNS-Server

        Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
        Start-Service sshd
        Set-Service -Name sshd -StartupType 'Automatic'
        New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
        </powershell>
        EOF

  tags = {
    Name = "bastion"
  }
}

resource "aws_security_group" "bastion" {
  name   = "bastion"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

/*resource "aws_security_group_rule" "outbound_icmp_win_server" {
  type              = "egress"
  security_group_id = aws_security_group.bastion.id

  from_port                = "-1"
  to_port                  = "-1"
  protocol                 = "icmp"
  source_security_group_id = aws_security_group.win_server.id
}

resource "aws_security_group_rule" "outbound_ssh_win_server" {
  type              = "egress"
  security_group_id = aws_security_group.bastion.id

  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.win_server.id
}

resource "aws_security_group_rule" "outbound_rdp_win_server" {
  type              = "egress"
  security_group_id = aws_security_group.bastion.id

  from_port                = 3389
  to_port                  = 3389
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.win_server.id
}

resource "aws_security_group_rule" "outbound_http_win_server" {
  type              = "egress"
  security_group_id = aws_security_group.bastion.id

  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.win_server.id
}

resource "aws_security_group_rule" "outbound_https_win_server" {
  type              = "egress"
  security_group_id = aws_security_group.bastion.id

  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.win_server.id
}

resource "aws_security_group_rule" "outbound_rds_sql_server" {
  type              = "egress"
  security_group_id = aws_security_group.bastion.id

  from_port                = 1433
  to_port                  = 1433
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_sqlserver.id
}*/

