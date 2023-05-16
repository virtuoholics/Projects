

output "certificate_arn" {
  value = aws_acm_certificate.default_cert.arn
}
