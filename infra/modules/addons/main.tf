
data "aws_caller_identity" "current" {
}

provider "helm" {
  kubernetes {
    config_context = var.cluster_arn
  }
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.15.1"
  service_account = kubernetes_service_account.tiller.metadata.0.name
  namespace       = kubernetes_service_account.tiller.metadata.0.namespace
  
  install_tiller = true
}

# resource "helm_release" "kube2iam" {
#   name       = "kube2iam"
#   repository = "stable"
#   chart      = "kube2iam"
#   namespace  = "kube-system"

#   values = [
#     file("${path.module}/config/kube2iam.yaml"),
#   ]

#   set {
#     name  = "extraArgs.base-role-arn"
#     value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/"
#   }

#   depends_on = [
#     kubernetes_service_account.tiller,
#     kubernetes_cluster_role_binding.tiller_clusterrolebinding,
#     #null_resource.helm_init_client,
#   ]
# }

# resource "kubernetes_service_account" "tiller" {
#   metadata {
#     name      = "tiller"
#     namespace = "kube-system"
#   }
# }

# resource "kubernetes_cluster_role_binding" "tiller_clusterrolebinding" {
#   metadata {
#     name = "tiller-clusterrolebinding"
#   }

#   subject {
#     kind      = "ServiceAccount"
#     name      = kubernetes_service_account.tiller.metadata[0].name
#     namespace = "kube-system"
#   }

#   role_ref {
#     kind      = "ClusterRole"
#     name      = "cluster-admin"
#     api_group = "rbac.authorization.k8s.io"
#   }
# }

