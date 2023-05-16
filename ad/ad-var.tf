variable "region" {}
variable "ad_domain" {}
variable "secret" {}
variable "ad_edition" {}
variable "ad_type" {}
variable "vpc_id" {}

variable "subnet_ids" {
  type = list(string)
}
