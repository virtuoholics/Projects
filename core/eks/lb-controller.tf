resource "helm_release" "lb_controller" {
  name       = "eks-lb-controller"
  repository = "https://aws.github.io/eks-charts/"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.4.1"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.devsecops_eks.id
  }

  set {
    name  = "image.tag"
    value = "v2.4.2"
  }

  set {
    name  = "replicaCount"
    value = 1
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.lb_controller.arn
  }

  # EKS FARGATE SPECIFIC
  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = data.aws_vpc.devsecops_eks.id
  }

  depends_on = [
    aws_eks_node_group.devsecops_eks,
  ]
}
