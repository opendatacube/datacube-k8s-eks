variable "flux_helm_operator_version" {
  default = "1.2.0"
}

variable "enabled_helm_versions" {
  type        = string
  description = "Helm options to support release versions"
  default     = "v2\\,v3"
}

resource "helm_release" "flux_helm_operator" {
  count      = var.flux_enabled ? 1 : 0
  name       = "helm-operator"
  repository = "https://charts.fluxcd.io"
  chart      = "helm-operator"
  version    = var.flux_helm_operator_version
  namespace  = "flux"

  set {
    name  = "git.ssh.secretName"
    value = "flux-git-deploy"
  }

  set {
    name  = "helm.versions"
    value = var.enabled_helm_versions
  }
}
