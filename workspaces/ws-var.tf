variable "vpc_id" {}
variable "region" {}
variable "bundle_id" {}
variable "directory_id" {}
variable "compute_type_name" {}

variable "subnet_ids" {
  type = list(string)
}
