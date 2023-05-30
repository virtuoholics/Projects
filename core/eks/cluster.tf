resource "aws_eks_cluster" "devsecops_eks" {
  name     = var.cluster_name
  version  = "1.24"
  role_arn = aws_iam_role.devsecops_eks.arn

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]

    subnet_ids = data.aws_subnets.devsecops_eks.ids
  }

  kubernetes_network_config {
    service_ipv4_cidr = "10.14.5.0/24"
  }

  tags = {
    Name = "devsecops-project"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster,
    aws_iam_role_policy_attachment.vpc_resource_controller,
  ]
}

resource "aws_iam_role" "devsecops_eks" {
  name = "devsecops-project"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.devsecops_eks.name
}

resource "aws_iam_role_policy_attachment" "vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.devsecops_eks.name
}

resource "null_resource" "kube_config_update" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${aws_eks_cluster.devsecops_eks.name} --region ${var.region}"
  }

  depends_on = [aws_eks_cluster.devsecops_eks]
}

