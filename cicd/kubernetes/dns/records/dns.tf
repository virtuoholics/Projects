data "aws_route53_zone" "app1" {
  name = var.dns_common_name
}

resource "aws_route53_record" "app1_nlb" {
  zone_id = data.aws_route53_zone.app1.id
  name    = "app1.${var.dns_common_name}"
  type    = "CNAME"
  records = ""
  ttl     = "600"
}
