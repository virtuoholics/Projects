
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  region     = "us-east-1"
  cidr_block = "10.0.0.0/16"
}
