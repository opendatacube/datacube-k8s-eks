
data "aws_caller_identity" "current" {
}

resource "helm_release" "kube2iam" {
  name       = "kube2iam"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "kube2iam"
  namespace  = "kube-system"

  values = [
    file("${path.module}/config/kube2iam.yaml"),
  ]

  set {
    name  = "extraArgs.base-role-arn"
    value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/"
  }

  # depends_on = [
  #   module.tiller,
  # ]
}

