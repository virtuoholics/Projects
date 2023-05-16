output "target_group_arns" {
  value = [aws_lb_target_group.winserver_nlb_8080.arn, aws_lb_target_group.winserver_nlb_8443.arn]
}
