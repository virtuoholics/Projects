
include "root" {
  path = find_in_parent_folders()
}

/*dependencies {
  paths = ["../vpc"]
}*/

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  dns_common_name = "test-domain.com"

  region = dependency.vpc.outputs.region
}
