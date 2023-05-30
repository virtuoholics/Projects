include "root" {
  path = find_in_parent_folders()
}

inputs = {
  region  = "us-east-1"
  dns_common_name = "customer.com"
}
