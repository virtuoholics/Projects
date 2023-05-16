resource "aws_acm_certificate" "default_cert" {
  domain_name = aws_route53_zone.test_domain.name
  subject_alternative_names = [
    "*.${var.dns_common_name}",
  ]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.default_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  depends_on = [
    aws_route53domains_registered_domain.virtuoholics
  ]
}
