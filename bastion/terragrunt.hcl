
include "root" {
  path = find_in_parent_folders()
}

/*dependencies {
  paths = ["../ad"]
}*/

dependency "common" {
  config_path = "../common"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  instance_type = "t2.micro"

  instance_profile = dependency.common.outputs.instance_profile
  keypair = dependency.common.outputs.keypair

  region    = dependency.vpc.outputs.region
  vpc_id    = dependency.vpc.outputs.vpc_id
  subnet_id = dependency.vpc.outputs.single_public_subnet
}
