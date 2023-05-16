variable "region" {}
variable "certificate_arn" {}
variable "vpc_id" {}

variable "subnets" {
  type = list(string)
}
