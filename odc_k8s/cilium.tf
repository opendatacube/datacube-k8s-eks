variable "cilium_enabled" {
  default = false
}

variable "cilium_version" {
  default = "1.7.4"
}

resource "helm_release" "cilium" {
  count      = var.cilium_enabled ? 1 : 0
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = var.cilium_version
  namespace  = "kube-system"

  set {
    name  = "global.cni.chainingMode"
    value = "aws-cni"
  }

  set {
    name  = "global.masquerade"
    value = false
  }

  set {
    name  = "global.tunnel"
    value = "disabled"
  }

  set {
    name  = "global.nodeinit.enabled"
    value = true
  }
}