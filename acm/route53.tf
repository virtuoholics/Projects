resource "aws_route53_zone" "test_domain" {
  name = var.dns_common_name
}

resource "aws_route53domains_registered_domain" "virtuoholics" {
  domain_name   = var.dns_common_name
  transfer_lock = false

  dynamic "name_server" {
    for_each = aws_route53_zone.test_domain.name_servers
    content {
      name = name_server.value
    }
  }
}

/*resource "aws_route53_record" "vault" {
  zone_id = aws_route53_zone.test_domain.id
  name    = "vault.${var.dns_common_name}"
  type    = "CNAME"
  records = [aws_lb.bastion.dns_name]
  ttl     = 600
}*/

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.default_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.test_domain.zone_id

  depends_on = [
    aws_route53domains_registered_domain.virtuoholics
  ]
}
