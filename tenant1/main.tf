provider "aws" {
  alias = "tenant1"

  region     = var.tenant1_region
  access_key = var.tenant1_key_id
  secret_key = var.tenant1_secret_key
}

module "tn1-project" {
  source = "./tn1-project"

  providers = {
    aws = aws.tenant1
  }

  az   = var.tenant1_region
  tgw1 = var.tgw1
  #tgw1-rtb = var.tgw1-rtb
  #receiver_accept = var.receiver_accept
}
