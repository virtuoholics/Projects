resource "null_resource" "devsecops_project_vault" {
  provisioner "local-exec" {
    command = <<EOT
kubectl create namespace app1
kubectl create serviceaccount app1 -n app1

helm repo add hashicorp "https://helm.releases.hashicorp.com"
helm repo update
helm install vault hashicorp/vault --namespace app1 --set server.dev.enabled=true --set injector.enabled=false --set csi.enabled=tru

helm repo add secrets-store-csi-driver "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
helm install csi secrets-store-csi-driver/secrets-store-csi-driver --namespace app1 --set syncSecret.enabled=true
EOT
  }
}
