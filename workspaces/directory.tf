resource "aws_workspaces_directory" "winserver" {
  directory_id = var.directory_id
  subnet_ids   = [for s in var.subnet_ids : s]

  self_service_permissions {
    change_compute_type  = false
    increase_volume_size = false
    rebuild_workspace    = false
    restart_workspace    = false # default - true
    switch_running_mode  = false
  }

  workspace_access_properties {
    device_type_android    = "ALLOW"
    device_type_chromeos   = "ALLOW"
    device_type_ios        = "ALLOW"
    device_type_linux      = "ALLOW"
    device_type_osx        = "ALLOW"
    device_type_web        = "ALLOW"
    device_type_windows    = "ALLOW"
    device_type_zeroclient = "DENY"
  }

  workspace_creation_properties {
    custom_security_group_id            = aws_security_group.workspaces_default.id
    default_ou                          = "OU=AWS,DC=Domain,DC=ad,DC=testdomain,DC=com"
    enable_internet_access              = true
    enable_maintenance_mode             = false # default - true
    user_enabled_as_local_administrator = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.service_access,
    aws_iam_role_policy_attachment.self_service_access
  ]

  tags = {
    Name = "winserver"
  }
}
