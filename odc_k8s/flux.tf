# Flux Addon
# ==========

variable "flux_enabled" {
  default = false
}

variable "fluxcd_flux_chart_version" {
  default = "1.0.0"
}

variable "fluxcd_helm_operator_chart_version" {
  default = "0.3.0"
}

variable "flux_git_repo_url" {
  type        = string
  description = "URL pointing to the git repository that flux will monitor and commit to"
  default     = "git@github.com:opendatacube/datacube-k8s-eks"
}

variable "flux_git_branch" {
  type        = string
  description = "Branch of the specified git repository to monitor and commit to"
  default     = "dev"
}

variable "flux_git_path" {
  type        = string
  description = "Relative path inside specified git repository to search for manifest files"
  default     = ""
}

variable "flux_git_label" {
  type        = string
  description = "Label prefix that is used to track flux syncing inside the git repository"
  default     = "flux-sync"
}

variable "flux_additional_args" {
  type        = string
  description = "Use additional arg for connect flux to fluxcloud. Syntext: --connect=ws://fluxcloud"
  default     = ""
}

resource "kubernetes_namespace" "flux" {
  count = var.flux_enabled ? 1 : 0

  metadata {
    name = "flux"

    labels = {
      managed-by = "Terraform"
    }
  }
}

data "template_file" "flux_config" {
  template = file("${path.module}/config/flux.yaml")
  vars = {
    git_repo_url = var.flux_git_repo_url
    git_branch = var.flux_git_branch
    git_path = var.flux_git_path
    git_label = var.cluster_id
    additional_args = var.flux_additional_args
  }
}

resource "helm_release" "flux" {
  count      = var.flux_enabled ? 1 : 0
  name       = "flux"
  repository = "https://charts.fluxcd.io"
  chart      = "flux"
  version    = var.fluxcd_flux_chart_version
  namespace  = kubernetes_namespace.flux[0].metadata[0].name

  values = [
    data.template_file.flux_config.rendered
  ]

  depends_on = [
    null_resource.apply_flux_crd,
    module.tiller,
  ]
}

resource "helm_release" "flux-helm-operator" {
  count      = var.flux_enabled ? 1 : 0
  name       = "helm-operator"
  repository = "https://charts.fluxcd.io"
  chart      = "helm-operator"
  version    = var.fluxcd_helm_operator_chart_version
  namespace  = kubernetes_namespace.flux[0].metadata[0].name

  set {
    name  = "git.ssh.secretName"
    value = "flux-git-deploy"
  }

  depends_on = [
    null_resource.apply_flux_crd,
    helm_release.flux,
    module.tiller,
  ]
}

data "http" "flux_helm_release_crd_yaml" {
  url = "https://raw.githubusercontent.com/fluxcd/helm-operator/chart-0.3.0/deploy/flux-helm-release-crd.yaml"
}


resource "null_resource" "apply_flux_crd" {
    count      = var.flux_enabled ? 1 : 0

  triggers = {
    cluster_updated                     = var.cluster_id
    kubernetes_namespace_updated        = kubernetes_namespace.flux[0].metadata[0].name

    # Special trigger: When using null_resource, you can use the triggers map both to signal when the provisioners
    # need to re-run (the usual purpose as above) and to retain values you can access via self during the destroy phase.
    # This avoids dependency issues during the destory phase
    install_kubectl = local.install_kubectl
    local_exec_interpreter = var.local_exec_interpreter
    flux_helm_release_crd_yaml = replace(data.http.flux_helm_release_crd_yaml.body, "\"", "\\\"")
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
