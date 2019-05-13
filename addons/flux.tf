resource "kubernetes_namespace" "flux" {
  count = "${var.flux_enabled ? 1 : 0}"
  metadata {
    name = "flux"

    labels {
        managed-by = "Terraform"
    }
  }
}

resource "helm_release" "flux" {
  count = "${var.flux_enabled ? 1 : 0}"
  name       = "flux"
  repository = "${data.helm_repository.weaveworks.metadata.0.name}"
  chart      = "flux"
  namespace  = "flux"

  values = [
    "${file("${path.module}/config/flux.yaml")}",
  ]

  set {
    name = "git.url"
    value = "${var.flux_git_repo_url}"
  }

  set {
    name = "git.branch"
    value = "${var.flux_git_branch}"
  }

  set {
    name = "git.path"
    value = "${var.flux_git_path}"
  }

  set {
    name = "git.label"
    value = "${var.flux_git_label}"
  }

  depends_on = ["kubernetes_namespace.flux"] 
}
