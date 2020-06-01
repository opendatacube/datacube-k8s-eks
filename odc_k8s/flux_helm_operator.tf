variable "flux_helm_operator_version" {
  default = "1.0.1"
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

# installing helm-operator CRD
resource "null_resource" "apply_flux_helm_operator_crd" {
  count = var.flux_enabled ? 1 : 0

  triggers = {
    cluster_updated              = var.cluster_id
    kubernetes_namespace_updated = kubernetes_namespace.flux[0].metadata[0].name
    flux_helm_operator_version   = var.flux_helm_operator_version
  }

  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_id} && kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/${var.flux_helm_operator_version}/deploy/crds.yaml"
  }
}