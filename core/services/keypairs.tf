data "aws_key_pair" "instances" {
  count              = length(local.keypairs)
  key_name           = local.keypairs[count.index]
  include_public_key = true
}

locals {
  keypairs = [
    "bastion",
    "jenkins",
    "nexus",
    "sonarqube"
  ]
}
