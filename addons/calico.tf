# Install calico using helm release: https://github.com/aws/eks-charts/tree/master/stable/aws-vpc-cni
resource "helm_release" "calico" {
  count      = 0
  name       = "calico-node"
  repository = "eks"
  chart      = "eks/aws-calico"
  namespace  = "kube-system"

  depends_on = [
    kubernetes_service_account.tiller,
    kubernetes_cluster_role_binding.tiller_clusterrolebinding,
    null_resource.repo_add_eks,
  ]
}