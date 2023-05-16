
include "root" {
  path = find_in_parent_folders()
}

/*dependencies {
  paths = ["../vpc", "../ad", "../common"]
}*/

dependency "common" {
  config_path = "../common"
}

dependency "ad" {
  config_path = "../ad"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  engine         = "sqlserver-se"
  instance_class = "db.m5.large" # db.m5.xlarge

  secret = dependency.common.outputs.rds_secret

  ad_domain_id = dependency.ad.outputs.ad_domain_id

  region         = dependency.vpc.outputs.region
  vpc_id         = dependency.vpc.outputs.vpc_id
  subnet_ids     = dependency.vpc.outputs.private_subnets
  vpc_cidr_block = dependency.vpc.outputs.vpc_cidr_block
}
