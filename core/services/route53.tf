resource "aws_route53_zone" "default" {
  name = var.dns_common_name
}

resource "aws_route53domains_registered_domain" "default" {
  domain_name   = var.dns_common_name
  transfer_lock = false

  dynamic "name_server" {
    for_each = aws_route53_zone.default.name_servers
    content {
      name = name_server.value
    }
  }
}

resource "aws_route53_record" "jenkins" {
  zone_id = aws_route53_zone.default.id
  name    = "jenkins.${var.dns_common_name}"
  type    = "CNAME"
  records = [aws_lb.services.dns_name]
  ttl     = 600
}

resource "aws_route53_record" "rancher" {
  zone_id = aws_route53_zone.default.id
  name    = "rancher.${var.dns_common_name}"
  type    = "CNAME"
  records = [aws_lb.services.dns_name]
  ttl     = 600
}

resource "aws_route53_record" "pgadmin" {
  zone_id = aws_route53_zone.default.id
  name    = "pgadmin.${var.dns_common_name}"
  type    = "CNAME"
  records = [aws_lb.services.dns_name]
  ttl     = 600
}

resource "aws_route53_record" "vault" {
  zone_id = aws_route53_zone.default.id
  name    = "vault.${var.dns_common_name}"
  type    = "CNAME"
  records = [aws_lb.services.dns_name]
  ttl     = 600
}

resource "aws_route53_record" "nexus" {
  zone_id = aws_route53_zone.default.id
  name    = "nexus.${var.dns_common_name}"
  type    = "CNAME"
  records = [aws_lb.services.dns_name]
  ttl     = 600
}

resource "aws_route53_record" "sonarqube" {
  zone_id = aws_route53_zone.default.id
  name    = "sonarqube.${var.dns_common_name}"
  type    = "CNAME"
  records = [aws_lb.services.dns_name]
  ttl     = 600
}
