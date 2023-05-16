
include "root" {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../win-server"]
}

dependency "common" {
  config_path = "../common"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  ad_domain  = "ad.testdomain.com"
  ad_edition = "Standard"
  ad_type    = "MicrosoftAD"

  secret = dependency.common.outputs.ad_secret

  region     = dependency.vpc.outputs.region
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets
}
