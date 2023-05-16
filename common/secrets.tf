resource "aws_secretsmanager_secret" "winserver" {
  count                   = length(data.aws_secretsmanager_random_password.winserver[*].id)
  name                    = "winserver_${local.secret_entities[count.index]}"
  recovery_window_in_days = 0

  depends_on = [data.aws_secretsmanager_random_password.winserver]
}

resource "aws_secretsmanager_secret_version" "winserver" {
  count         = length(data.aws_secretsmanager_random_password.winserver[*].id)
  secret_id     = aws_secretsmanager_secret.winserver[count.index].id
  secret_string = data.aws_secretsmanager_random_password.winserver[count.index].random_password

  depends_on = [data.aws_secretsmanager_random_password.winserver]
}

data "aws_secretsmanager_random_password" "winserver" {
  count               = 2
  password_length     = 14
  include_space       = false
  exclude_punctuation = true
}

locals {
  secret_entities = [
    "active_directory",
    "rds_sqlserver",
  ]
}
