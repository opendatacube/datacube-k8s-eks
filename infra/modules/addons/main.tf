provider "helm" {
  # kubernetes {
  #   config_path = "$HOME/.kube/config-eks.yaml"
  # }
}

provider "kubernetes" {
  # load_config_file       = "$HOME/.kube/config-eks.yaml"
  # config_context_cluster = "aws"
}

# region and kube2iam required for most add-ons

data "aws_region" "current" {}

resource "helm_release" "kube2iam" {
  name       = "kube2iam"
  repository = "{data.helm_repository.stable.metadata.0.name}"
  chart      = "kube2iam"
  namespace  = "kube-system"

  set {
    name  = "extraArgs.base-role-arn"
    value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/"
  }
}