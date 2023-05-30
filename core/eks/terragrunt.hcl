
include "root" {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../ec2"]
}

inputs = {
  region       = "us-east-1"
  cluster_name = "devsecops-project"
}
