resource "aws_iam_instance_profile" "instances" {
  name = "instances"
  role = aws_iam_role.instances.name
}

resource "aws_iam_role" "instances" {
  name               = "instances"
  assume_role_policy = data.aws_iam_policy_document.instances.json
}

data "aws_iam_policy_document" "instances" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "instance_ssm_connection" {
  role       = aws_iam_role.instances.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "instances" {
  role       = aws_iam_role.instances.name
  policy_arn = aws_iam_policy.instances.arn
}

resource "aws_iam_policy" "instances" {
  name = "instances"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "eks:*",
        "ecr:*",
        "securityhub:*",
        "elasticfilesystem:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
