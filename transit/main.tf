provider "aws" {
  alias = "transit1"

  region     = var.transit_region1
  access_key = var.transit_key_id
  secret_key = var.transit_secret_key
}

provider "aws" {
  alias = "transit2"

  region     = var.transit_region2
  access_key = var.transit_key_id
  secret_key = var.transit_secret_key
}

provider "aws" {
  alias = "transit3"

  region     = var.transit_region3
  access_key = var.transit_key_id
  secret_key = var.transit_secret_key
}

module "gateway1" {
  source = "./gateway1"

  providers = {
    aws = aws.transit1
  }

  cid-multi1              = var.cid-multi1
  cid-tenant1             = var.cid-tenant1
  transit-vpc1-attachment = module.transit1-vpc.transit-vpc1-attachment-id
  tgw2                    = module.gateway2.tgw2-id
  tgw3                    = module.gateway3.tgw3-id
}

module "gateway2" {
  source = "./gateway2"

  providers = {
    aws = aws.transit2
  }

  cid-multi2              = var.cid-multi2
  cid-tenant2-1           = var.cid-tenant2-1
  cid-tenant2-2           = var.cid-tenant2-2
  transit-vpc2-attachment = module.transit2-vpc.transit-vpc2-attachment-id
  tgw3                    = module.gateway3.tgw3-id
  tgw1-peering-accepter   = module.gateway1.tgw1-tgw2-peering-attachment-id
}

module "gateway3" {
  source = "./gateway3"

  providers = {
    aws = aws.transit3
  }

  cid-tenant3-1           = var.cid-tenant3-1
  cid-tenant3-2           = var.cid-tenant3-2
  transit-vpc3-attachment = module.transit3-vpc.transit-vpc3-attachment-id
  tgw1-peering-accepter   = module.gateway1.tgw1-tgw3-peering-attachment-id
  tgw2-peering-accepter   = module.gateway2.tgw2-tgw3-peering-attachment-id
}

module "transit1-vpc" {
  source = "./transit1-vpc"

  providers = {
    aws = aws.transit1
  }

  az   = var.transit_region1
  tgw1 = module.gateway1.tgw1-id
  #tgw1-rtb = module.gateway1.tgw1-rtb-id
}

module "transit2-vpc" {
  source = "./transit2-vpc"

  providers = {
    aws = aws.transit2
  }

  az   = var.transit_region2
  tgw2 = module.gateway2.tgw2-id
  #tgw2-rtb = module.gateway2.tgw2-rtb-id
}

module "transit3-vpc" {
  source = "./transit3-vpc"

  providers = {
    aws = aws.transit3
  }

  az   = var.transit_region3
  tgw3 = module.gateway3.tgw3-id
  #tgw3-rtb = module.gateway3.tgw3-rtb-id
}
