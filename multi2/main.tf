provider "aws" {
  alias = "multi2"

  region     = var.multi_region2
  access_key = var.multi_key_id
  secret_key = var.multi_secret_key
}

module "multi2-project" {
  source = "./multi2-project"

  providers = {
    aws = aws.multi2
  }

  az   = var.multi_region2
  tgw2 = var.tgw2
  #tgw2-rtb = var.tgw2-rtb
  #receiver_accept = var.receiver_accept
}
