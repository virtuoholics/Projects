variable "region" {}
variable "vpc_id" {}
variable "keypair" {}
variable "instance_type" {}
variable "instance_profile" {}
variable "bastion_sg" {}
variable "subnets" {}

variable "target_group_arns" {
  type = list(string)
}
