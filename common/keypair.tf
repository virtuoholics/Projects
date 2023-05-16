data "aws_key_pair" "default" {
  key_name           = "TestKP1" # kp-useast2-2
  include_public_key = true
}
