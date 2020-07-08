# Flux Addon
# ==========

variable "flux_enabled" {
  default = false
}

variable "flux_version" {
  default = "1.3.0"
}

variable "flux_git_repo_url" {
  type        = string
  description = "URL pointing to the git repository that flux will monitor and commit to"
  default     = ""
}

variable "flux_git_branch" {
  type        = string
  description = "Branch of the specified git repository to monitor and commit to"
  default     = ""
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

variable "flux_registry_exclude_images" {
  type        = string
  description = "comma separated string lists of registry images to exclud from flux auto release"
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
    git_repo_url            = var.flux_git_repo_url
    git_branch              = var.flux_git_branch
    git_path                = var.flux_git_path
    git_label               = var.cluster_id
    additional_args         = var.flux_additional_args
    registry_exclude_images = var.flux_registry_exclude_images
  }
}

resource "helm_release" "flux" {
  count      = var.flux_enabled ? 1 : 0
  name       = "flux"
  repository = "https://charts.fluxcd.io"
  chart      = "flux"
  version    = var.flux_version
  namespace  = kubernetes_namespace.flux[0].metadata[0].name

  values = [
    data.template_file.flux_config.rendered
  ]
}
