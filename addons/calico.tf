# Install calico using helm release: https://github.com/aws/eks-charts/tree/master/stable/aws-vpc-cni
resource "helm_release" "aws_vpc_cni" {
  name       = "aws-vpc-cni"
  repository = "eks"
  chart      = "aws-vpc-cni"
  namespace  = "kube-system"

  depends_on = [
    kubernetes_service_account.tiller,
    kubernetes_cluster_role_binding.tiller_clusterrolebinding,
    null_resource.repo_add_aws_eks,
  ]
}