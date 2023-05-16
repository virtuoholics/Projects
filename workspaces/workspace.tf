resource "aws_workspaces_workspace" "winserver" {
  directory_id = aws_workspaces_directory.winserver.id
  bundle_id    = var.bundle_id
  user_name    = "raza.lakhani"

  workspace_properties {
    compute_type_name                         = var.compute_type_name
    user_volume_size_gib                      = 50
    root_volume_size_gib                      = 80
    running_mode                              = "AUTO_STOP"
    running_mode_auto_stop_timeout_in_minutes = 60 # default
  }

  tags = {
    Name = "winserver"
  }
}
