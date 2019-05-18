data "aws_eks_cluster" "eks" {
  name = "${var.cluster_name}"
}

data "aws_caller_identity" "current" {}

provider "helm" {
  kubernetes {
    config_context = "${data.aws_eks_cluster.eks.arn}"
  }
  install_tiller = "${var.install_tiller}"
  service_account = "${var.tiller_service_account}"
}

provider "kubernetes" {
  config_context_cluster = "${data.aws_eks_cluster.eks.arn}"
}

# region and kube2iam required for most add-ons
data "aws_region" "current" {}

resource "helm_release" "kube2iam" {
  name       = "kube2iam"
  repository = "${data.helm_repository.stable.metadata.0.name}"
  chart      = "kube2iam"
  namespace  = "kube-system"

  values = [
    "${file("${path.module}/config/kube2iam.yaml")}",
  ]

  set {
    name  = "extraArgs.base-role-arn"
    value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/"
  }
}