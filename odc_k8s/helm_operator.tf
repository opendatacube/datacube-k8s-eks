variable "helm_operator_version" {
  default = "1.0.1"
}

variable "enabled_helm_versions" {
  default = "v2\\,v3"
}

resource "helm_release" "flux_helm_operator" {
  name       = "helm-operator"
  repository = "https://charts.fluxcd.io"
  chart      = "helm-operator"
  version    = var.helm_operator_version
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

//# installing helm-operator CRD
//resource "null_resource" "apply_helm_operator_crd" {
//  count      = var.flux_enabled && (!var.install_aws_cli || !var.install_kubectl) ? 1 : 0
//  provisioner "local-exec" {
//    command = "aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_id} && kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/${var.helm_operator_version}/deploy/crds.yaml"
//  }
//
//  provisioner "local-exec" {
//    when    = destroy
//    command = "aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_id} && kubectl delete -f https://raw.githubusercontent.com/fluxcd/helm-operator/${var.helm_operator_version}/deploy/crds.yaml"
//  }
//}

# installing extra softwares + helm-operator CRD
data "http" "flux_helm_operator_crd_yaml" {
  url = "https://raw.githubusercontent.com/fluxcd/helm-operator/${var.helm_operator_version}/deploy/crds.yaml"
}

resource "null_resource" "apply_flux_helm_operator_crd" {
  count      = var.flux_enabled ? 1 : 0

  triggers = {
    cluster_updated                     = var.cluster_id
    kubernetes_namespace_updated        = kubernetes_namespace.flux[0].metadata[0].name

    # Special trigger: When using null_resource, you can use the triggers map both to signal when the provisioners
    # need to re-run (the usual purpose as above) and to retain values you can access via self during the destroy phase.
    # This avoids dependency issues during the destory phase
    install_kubectl = local.install_kubectl
    local_exec_interpreter = var.local_exec_interpreter
    flux_helm_release_crd_yaml = replace(data.http.flux_helm_operator_crd_yaml.body, "\"", "\\\"")
  }

  depends_on = [
    kubernetes_namespace.flux,
    #    kubernetes_config_map.aws_auth,
  ]

  provisioner "local-exec" {
    interpreter = [self.triggers.local_exec_interpreter, "-c"]
    command = join("\n", [self.triggers.install_kubectl, "crd_yaml=\"${self.triggers.flux_helm_release_crd_yaml}\"", "kubectl apply -f - <<< \"$crd_yaml\" "])
  }


  provisioner "local-exec" {
    when    = destroy
    interpreter = [self.triggers.local_exec_interpreter, "-c"]
    command = join("\n", [self.triggers.install_kubectl, "crd_yaml=\"${self.triggers.flux_helm_release_crd_yaml}\"", "kubectl delete -f - <<< \"$crd_yaml\" "])
  }

}