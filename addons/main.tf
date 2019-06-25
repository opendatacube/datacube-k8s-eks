terraform {
  required_version = ">= 0.12.0"

  backend "s3" {
    # Force encryption
    encrypt = true
  }
}

data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}

data "aws_caller_identity" "current" {
}

provider "helm" {
  kubernetes {
    config_context = data.aws_eks_cluster.eks.arn
  }

  # Tiller is installed on cluster and intialized by null_resource.helm_init_client
  install_tiller = false
}

provider "kubernetes" {
  version = "~> 1.7"
  config_context_cluster = data.aws_eks_cluster.eks.arn
}

# region and kube2iam required for most add-ons
data "aws_region" "current" {
}

resource "helm_release" "kube2iam" {
  name       = "kube2iam"
  repository = "stable"
  chart      = "kube2iam"
  namespace  = "kube-system"

  values = [
    file("${path.module}/config/kube2iam.yaml"),
  ]

  set {
    name  = "extraArgs.base-role-arn"
    value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/"
  }

  depends_on = [
    kubernetes_service_account.tiller,
    kubernetes_cluster_role_binding.tiller_clusterrolebinding,
    null_resource.helm_init_client,
  ]
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller_clusterrolebinding" {
  metadata {
    name = "tiller-clusterrolebinding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.tiller.metadata[0].name
    namespace = "kube-system"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }
}

