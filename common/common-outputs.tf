output "instance_profile" {
  value     = aws_iam_instance_profile.winserver.name
  sensitive = true
}

output "keypair" {
  value = data.aws_key_pair.default.key_name
}

output "ad_secret" {
  value     = aws_secretsmanager_secret_version.winserver[0].secret_string
  sensitive = true
}

output "rds_secret" {
  value     = aws_secretsmanager_secret_version.winserver[1].secret_string
  sensitive = true
}
