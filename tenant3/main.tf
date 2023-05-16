provider "aws" {
  alias = "tenant3"

  region     = var.tenant3_region
  access_key = var.tenant3_key_id
  secret_key = var.tenant3_secret_key
}

module "tn3-project" {
  source = "./tn3-project"

  providers = {
    aws = aws.tenant3
  }

  az   = var.tenant3_region
  tgw3 = var.tgw3
  #tgw3-rtb = var.tgw3-rtb
  #receiver_accept = var.receiver_accept
}
