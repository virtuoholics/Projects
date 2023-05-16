data "aws_iam_policy_document" "workspaces" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["workspaces.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "workspaces" {
  name               = "winserver-workspaces"
  assume_role_policy = data.aws_iam_policy_document.workspaces.json
}

resource "aws_iam_role_policy_attachment" "service_access" {
  role       = aws_iam_role.workspaces.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkSpacesServiceAccess"
}

resource "aws_iam_role_policy_attachment" "self_service_access" {
  role       = aws_iam_role.workspaces.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkSpacesSelfServiceAccess"
}
