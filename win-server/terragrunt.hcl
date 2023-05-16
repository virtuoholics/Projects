
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

dependency "lb" {
  config_path = "../lb"
}

dependency "bastion" {
  config_path = "../bastion"
}

inputs = {
  instance_type = "t2.micro"

  instance_profile = dependency.common.outputs.instance_profile
  keypair          = dependency.common.outputs.keypair

  target_group_arns = dependency.lb.outputs.target_group_arns

  bastion_sg = dependency.bastion.outputs.bastion_sg_id

  region  = dependency.vpc.outputs.region
  vpc_id  = dependency.vpc.outputs.vpc_id
  subnets = dependency.vpc.outputs.single_private_subnet
}
