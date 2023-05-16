provider "aws" {
  alias = "tenant2"

  region     = var.tenant2_region
  access_key = var.tenant2_key_id
  secret_key = var.tenant2_secret_key
}

module "tn2-project" {
  source = "./tn2-project"

  providers = {
    aws = aws.tenant2
  }

  az   = var.tenant2_region
  tgw2 = var.tgw2
  #tgw2-rtb = var.tgw2-rtb
  #receiver_accept = var.receiver_accept
}
