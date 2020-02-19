variable "calico_enabled" {
  default     = false
  description = "Whether to install calico to your EKS cluster"
}

# Install calico using helm release: https://github.com/aws/eks-charts/tree/master/stable/aws-vpc-cni
# TODO: Getting error installing calico using helm install so used null_resource instead
#        helm install calico-node --namespace kube-system eks/aws-calico
#        Error: failed to install CRD crds/kustomization.yaml: unable to recognize "": no matches for kind "Kustomization" in version "kustomize.config.k8s.io/v1beta1"
//resource "helm_release" "calico" {
//  count      = var.calico_enabled ? 1 : 0
//  name       = "calico-node"
//  repository = "eks"
//  chart      = "eks/aws-calico"
//  namespace  = "kube-system"
//
//  depends_on = [
//    kubernetes_service_account.tiller,
//    kubernetes_cluster_role_binding.tiller_clusterrolebinding,
//    null_resource.repo_add_eks,
//  ]
//}

resource "null_resource" "install_calico" {
  count      = var.calico_enabled ? 1 : 0
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.6/config/v1.6/calico.yaml"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.6/config/v1.6/calico.yaml || true"
  }
}