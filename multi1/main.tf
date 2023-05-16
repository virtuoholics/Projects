provider "aws" {
  alias = "multi1"

  region     = var.multi_region1
  access_key = var.multi_key_id
  secret_key = var.multi_secret_key
}

module "multi1-project" {
  source = "./multi1-project"

  providers = {
    aws = aws.multi1
  }

  az   = var.multi_region1
  tgw1 = var.tgw1
  #tgw1-rtb = var.tgw1-rtb
  #receiver_accept = var.receiver_accept
}
