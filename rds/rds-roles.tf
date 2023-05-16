

resource "aws_iam_role" "winserver_rds" {
  name               = "winserver-rds"
  assume_role_policy = data.aws_iam_policy_document.winserver_rds.json
}

resource "aws_iam_role" "winserver_rds_s3" {
  name               = "winserver-rds-s3"
  assume_role_policy = data.aws_iam_policy_document.winserver_rds.json
}

data "aws_iam_policy_document" "winserver_rds" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "winserver_rds_s3" {
  name = "winserver-rds-s3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ds:DescribeDirectories", 
        "ds:AuthorizeApplication", 
        "ds:UnauthorizeApplication",
        "ds:GetAuthorizedApplicationDetails",
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "winserver_rds_s3" {
  role       = aws_iam_role.winserver_rds_s3.name
  policy_arn = aws_iam_policy.winserver_rds_s3.arn
}

resource "aws_db_instance_role_association" "winserver_rds_s3" {
  db_instance_identifier = aws_db_instance.winserver_rds_sqlserver.id
  feature_name           = "S3_INTEGRATION"
  role_arn               = aws_iam_role.winserver_rds.arn
}

resource "aws_iam_role_policy_attachment" "winserver_rds" {
  role       = aws_iam_role.winserver_rds.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSDirectoryServiceAccess"
}

/*"Condition": {
        "StringEquals": {
          "aws:SourceArn": [
              "arn:aws:rds:us-east-2:312803492278:db:winserver-rds-sqlserver"
          ]
        }
      }*/
