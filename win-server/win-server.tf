resource "aws_launch_configuration" "winserver" {
  name                 = "winserver-win-server-test"
  image_id             = "ami-064d05b4fe8515623" # ami-012bb86d0081c5240 - Microsoft Windows Server 2022 Base (us-east-2)
  instance_type        = var.instance_type       # r5a.xlarge
  security_groups      = [aws_security_group.winserver.id]
  iam_instance_profile = var.instance_profile
  key_name             = var.keypair

  user_data = <<-EOF
        <powershell>
        New-NetFirewallRule -DisplayName "ALLOW TCP PORT 8080" -Direction inbound -Profile Any -Action Allow -LocalPort 8080 -Protocol TCP
        New-NetFirewallRule -DisplayName "ALLOW TCP PORT 8443" -Direction inbound -Profile Any -Action Allow -LocalPort 8443 -Protocol TCP
        Enable-NetFirewallRule -Name *ICMP4*

        $websiteName = "main"
        $websiteAppPoolName = "winserver"
        $dnsName = 'www.testdomain.com'
        $newCert = New-SelfSignedCertificate -DnsName $dnsName -CertStoreLocation cert:\LocalMachine\My

        $tempFolder = "C:\tempUnzip"
        $artifactName = "dist.zip"
        $zippedAppName = "SampleDeployableApp.zip"
        $s3Bucket = "s3://winserver-code-artifacts/sample"

        New-Item "C:\$websiteAppPoolName" -ItemType Directory
        New-Item -Path "C:\$websiteAppPoolName\index.html" -ItemType File -Value "Hello from WIN-SERVER IIS web server." -Force
        New-Item "C:\artifacts" -ItemType Directory
        New-Item "$tempFolder" -ItemType Directory


        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        choco install awscli 7zip webdeploy -y                


        Import-Module Servermanager
        Install-WindowsFeature -Name Web-Server -IncludeManagementTools
        
        New-WebAppPool -Name $websiteAppPoolName -Verbose
        New-Website -Name $websiteName -Port 8080 -ApplicationPool $websiteAppPoolName -PhysicalPath "C:\$websiteAppPoolName" -Force
        New-WebBinding -Name $websiteName -IPAddress "*" -Port 8443 -Protocol "https"
        $binding = Get-WebBinding -Name $websiteName -Protocol "https"
        $binding.AddSslCertificate($newCert.GetCertHashString(), "my")
        Start-WebSite -Name $websiteName
        Get-WindowsFeature -Name Web-Server


        Install-WindowsFeature -Name GPMC,RSAT-AD-PowerShell,RSAT-AD-AdminCenter,RSAT-ADDS-Tools,RSAT-DNS-Server
        </powershell>
        EOF

  /*user_data = <<-EOF
        <powershell>
        Install-WindowsFeature -Name Web-App-Dev -IncludeAllSubFeature
        Import-Module WebAdministration

        aws s3 cp "$s3Bucket/$artifactName" C:\artifacts\"$artifactName"
        7z e C:\artifacts\"$artifactName" -o"$tempFolder"
        Set-Alias msdeploy -Value 'C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe'

        $msdeployArguments =
          '-source:package="C:\tempUnzip\$zippedAppName"',
          '-dest:auto,includeAcls="False"',
          '-verb:sync',
          '-disableLink:AppPoolExtension',
          '-disableLink:ContentExtension',
          '-disableLink:CertificateExtension',
          '-setParam:name="IIS', 'Web', 'Application', 'Name",value="$websiteName"'

        msdeploy $msdeployArguments
        rm -Recurse -Force $tempFolder
        

        Install-WindowsFeature MSMQ-Services
        Enable-WindowsOptionalFeature -Online -FeatureName 'MSMQ-Server' -All -NoRestart


        Install-WindowsFeature Net-Framework-Core -source \\network\share\sxs


        Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.10.2/python-3.10.2-amd64.exe" -OutFile "python-3.10.2-amd64.exe"
        .\python-3.10.2-amd64.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        </powershell>
        EOF*/

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "winserver" {
  name                      = aws_launch_configuration.winserver.name
  launch_configuration      = aws_launch_configuration.winserver.name
  vpc_zone_identifier       = [var.subnets]
  health_check_type         = "ELB"
  health_check_grace_period = 900
  target_group_arns         = [for arn in var.target_group_arns : arn]

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  tag {
    key                 = "Name"
    value               = "winserver-test"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "winserver" {
  name   = "winserver"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 3389
    to_port         = 3389
    protocol        = "tcp"
    security_groups = [var.bastion_sg]
  }

  ingress {
    from_port       = "-1"
    to_port         = "-1"
    protocol        = "icmp"
    security_groups = [var.bastion_sg]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  /*ingress {
    from_port   = 1812
    to_port     = 1812
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1645
    to_port     = 1645
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }*/

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "winserver"
  }
}

