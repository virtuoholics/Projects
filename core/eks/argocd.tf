resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "3.35.4"
  create_namespace = true

  # There could be many settings, so it's preferred to fetch values from a file instead of writing many set{} blocks.
  values = [file("./argocd-values.yaml")]

  depends_on = [
    aws_eks_node_group.devsecops_eks,
  ]
}
