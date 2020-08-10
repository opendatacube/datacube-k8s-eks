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

# installing extra softwares + helm-operator CRD
resource "null_resource" "apply_flux_helm_operator_crd" {
  count = var.flux_enabled ? 1 : 0

  triggers = {
    cluster_updated              = var.cluster_id
    kubernetes_namespace_updated = kubernetes_namespace.flux[0].metadata[0].name

    # Special trigger: When using null_resource, you can use the triggers map both to signal when the provisioners
    # need to re-run (the usual purpose as above) and to retain values you can access via self during the destroy phase.
    # This avoids dependency issues during the destory phase
    install_kubectl        = local.install_kubectl
    local_exec_interpreter = var.local_exec_interpreter
  }

  depends_on = [
    kubernetes_namespace.flux,
    #    kubernetes_config_map.aws_auth,
  ]

  provisioner "local-exec" {
    interpreter = [self.triggers.local_exec_interpreter, "-c"]
    command     = join("\n", [self.triggers.install_kubectl, "kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/${var.flux_helm_operator_version}/deploy/crds.yaml"])
  }


  provisioner "local-exec" {
    when        = destroy
    interpreter = [self.triggers.local_exec_interpreter, "-c"]
    command     = join("\n", [self.triggers.install_kubectl, "kubectl delete -f https://raw.githubusercontent.com/fluxcd/helm-operator/${var.flux_helm_operator_version}/deploy/crds.yaml"])
  }

}