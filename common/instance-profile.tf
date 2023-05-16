resource "aws_iam_instance_profile" "winserver" {
  name = "ad-rds-s3"
  role = aws_iam_role.winserver.name
}

resource "aws_iam_role" "winserver" {
  name               = "winserver"
  assume_role_policy = data.aws_iam_policy_document.winserver.json
}

data "aws_iam_policy_document" "winserver" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "winserver" {
  count      = length(local.ssm_policies)
  role       = aws_iam_role.winserver.name
  policy_arn = local.ssm_policies[count.index]
}

resource "aws_iam_policy" "winserver" {
  name = "winserver"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "rds:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

locals {
  ssm_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "${aws_iam_policy.winserver.arn}",
  ]
}
