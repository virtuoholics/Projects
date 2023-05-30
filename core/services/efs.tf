resource "aws_efs_file_system" "instances" {
  creation_token = "instances"
  encrypted      = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "instances"
  }
}

resource "aws_efs_mount_target" "instances" {
  file_system_id  = aws_efs_file_system.instances.id
  subnet_id       = aws_subnet.eks_2.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.instances.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_security_group" "efs" {
  name   = "efs"
  vpc_id = aws_vpc.devsecops_project.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.devsecops_project.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "efs"
  }
}

