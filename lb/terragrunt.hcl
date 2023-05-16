
include "root" {
  path = find_in_parent_folders()
}

/*dependencies {
  paths = ["../vpc", "../acm"]
}*/

dependency "vpc" {
  config_path = "../vpc"
}

dependency "acm" {
  config_path = "../acm"
}

inputs = {
  certificate_arn = dependency.acm.outputs.certificate_arn

  region  = dependency.vpc.outputs.region
  vpc_id  = dependency.vpc.outputs.vpc_id
  subnets = dependency.vpc.outputs.public_subnets
}
