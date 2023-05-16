variable "region" {}
variable "secret" {}
variable "engine" {}
variable "instance_class" {}
variable "vpc_id" {}
variable "vpc_cidr_block" {}
variable "ad_domain_id" {}

variable "subnet_ids" {
  type = list(string)
}
