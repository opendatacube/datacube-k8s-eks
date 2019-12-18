# Flux Addon
# ==========

variable "flux_enabled" {
  default = false
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

resource "kubernetes_namespace" "flux" {
  count = var.flux_enabled ? 1 : 0

  metadata {
    name = "flux"

    labels = {
      managed-by = "Terraform"
    }
  }
}

# resource "helm_release" "flux" {
#   count      = var.flux_enabled ? 1 : 0
#   name       = "flux"
#   repository = "https://fluxcd.github.io/flux"
#   chart      = "flux"
#   namespace  = "flux"

#   values = [
#     file("${path.module}/config/flux.yaml"),
#   ]

#   set {
#     name  = "git.url"
#     value = var.flux_git_repo_url
#   }

#   set {
#     name  = "git.branch"
#     value = var.flux_git_branch
#   }

#   set {
#     name  = "git.path"
#     value = var.flux_git_path
#   }

#   set {
#     name  = "git.label"
#     value = var.flux_git_label
#   }

#   depends_on = [
#     kubernetes_namespace.flux,
#   ]
# }


resource "null_resource" "apply_flux_crd" {
    count      = var.flux_enabled ? 1 : 0

  triggers = {
    cluster_updated                     = data.aws_eks_cluster.cluster.id
    kubernetes_namespace_updated        = kubernetes_namespace.flux.*.id
  }

  depends_on = [
    data.aws_eks_cluster.cluster,
    kubernetes_namespace.flux,
    ]

  provisioner "local-exec" {
    interpreter = local.interpreter
    command = join("\n", [local.install_kubectl, "kubectl apply -f https://raw.githubusercontent.com/fluxcd/flux/helm-0.10.1/deploy-helm/flux-helm-release-crd.yaml"])
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl destroy -f https://raw.githubusercontent.com/fluxcd/flux/helm-0.10.1/deploy-helm/flux-helm-release-crd.yaml"
  }

}
