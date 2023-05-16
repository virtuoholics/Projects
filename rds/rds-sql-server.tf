resource "aws_db_instance" "winserver_rds_sqlserver" {
  allocated_storage        = 20 #change this as per requirment
  max_allocated_storage    = 30 #change this as per requirment
  db_subnet_group_name     = aws_db_subnet_group.winserver_rds_sqlserver.name
  delete_automated_backups = false
  deletion_protection      = false # default
  engine                   = var.engine
  engine_version           = "15.00"
  identifier               = "winserver-rds-sqlserver"
  instance_class           = var.instance_class
  password                 = var.secret
  port                     = 1433  # default
  publicly_accessible      = false # default
  skip_final_snapshot      = true
  storage_type             = "gp2" # default
  timezone                 = "Central Standard Time"
  username                 = "Admin"
  vpc_security_group_ids   = [aws_security_group.winserver_rds_sqlserver.id]
  license_model            = "license-included"
  domain                   = var.ad_domain_id
  domain_iam_role_name     = aws_iam_role.winserver_rds.name
  apply_immediately        = true
  #multi_az                    = true
  #backup_retention_period     = 1

  timeouts {
    create = "90m"
  }

  lifecycle {
    ignore_changes = ["password"]
  }
}

resource "aws_db_subnet_group" "winserver_rds_sqlserver" {
  name       = "winserver-sql-server"
  subnet_ids = [for s in var.subnet_ids : s]
}

resource "aws_security_group" "winserver_rds_sqlserver" {
  name   = "winserver-sql-server"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "winserver-sql-server"
  }
}
