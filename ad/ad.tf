resource "aws_directory_service_directory" "ad" {
  name     = var.ad_domain
  password = var.secret
  edition  = var.ad_edition
  type     = var.ad_type

  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = [for s in var.subnet_ids : s]
  }

  lifecycle {
    ignore_changes = ["password"]
  }

  tags = {
    Project = "active-directory"
  }
}

resource "aws_vpc_dhcp_options" "vpc_dhcp_options" {
  domain_name         = aws_directory_service_directory.ad.name
  domain_name_servers = aws_directory_service_directory.ad.dns_ip_addresses

}
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = var.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.vpc_dhcp_options.id
}

resource "aws_ssm_document" "ad_join_domain" {
  name          = "ad-join-domain"
  document_type = "Command"
  content = jsonencode(
    {
      "schemaVersion" = "2.2"
      "description"   = "aws:domainJoin"
      "mainSteps" = [
        {
          "action" = "aws:domainJoin",
          "name"   = "domainJoin",
          "inputs" = {
            "directoryId" : aws_directory_service_directory.ad.id
            "directoryName" : aws_directory_service_directory.ad.name
            "dnsIpAddresses" : aws_directory_service_directory.ad.dns_ip_addresses
          }
        }
      ]
    }
  )
}

resource "aws_ssm_association" "windows_servers" {
  name = aws_ssm_document.ad_join_domain.name
  targets {
    key    = "InstanceIds"
    values = ["*"]
  }
}

data "aws_security_group" "ad" {
  filter {
    name   = "description"
    values = ["AWS created security group for ${aws_directory_service_directory.ad.id} directory controllers"]
  }

  depends_on = [aws_directory_service_directory.ad]
}

resource "aws_security_group_rule" "allow_ecs-private_outbound" {
  type              = "egress"
  security_group_id = data.aws_security_group.ad.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
