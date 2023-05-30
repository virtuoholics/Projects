data "aws_iam_policy_document" "lb_controller" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "lb_controller" {
  assume_role_policy = data.aws_iam_policy_document.lb_controller.json
  name               = "aws-load-balancer-controller"
}

resource "aws_iam_policy" "lb_controller" {
  policy = file("./AWSLoadBalancerController.json")
  name   = "AWSLoadBalancerController-main"
}

resource "aws_iam_role_policy_attachment" "lb_controller" {
  role       = aws_iam_role.lb_controller.name
  policy_arn = aws_iam_policy.lb_controller.arn
}


