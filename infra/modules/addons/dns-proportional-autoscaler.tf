# ======================================
# 
variable "dns_proportional_autoscaler_enabled" {
  default = false
}

variable "dns_proportional_autoscaler_coresPerReplica" {
  default = 256
}
variable "dns_proportional_autoscaler_nodesPerReplica" {
  default = 16
}
variable "dns_proportional_autoscaler_minReplica" {
  default = 2
}


resource "kubernetes_deployment" "dns_proportional_autoscaler" {
  count = var.dns_proportional_autoscaler_enabled ? 1 : 0
  metadata {
    name      = "dns-proportional-autoscaler"
    namespace = "kube-system"
    labels = {
      k8s-app = "dns-autoscaler"
    }
  }

  spec {
    selector {
      match_labels = {
        k8s-app = "dns-autoscaler"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "dns-autoscaler"
        }
      }

      spec {
        container {
          image = "k8s.gcr.io/cluster-proportional-autoscaler-amd64:1.6.0"
          name  = "autoscaler"

          resources{
            requests{
              cpu    = "20m"
              memory = "10Mi"
            }
          }
          # When cluster is using large nodes(with more cores), "coresPerReplica" should dominate.
          # If using small nodes, "nodesPerReplica" should dominate.
          command = ["/cluster-proportional-autoscaler",
                     "--namespace=kube-system", 
                     "--configmap=dns-autoscaler", 
                     "--target=Deployment/coredns",
                     "--default-params={\"linear\":{\"coresPerReplica\":${var.dns_proportional_autoscaler_coresPerReplica},\"nodesPerReplica\":${var.dns_proportional_autoscaler_nodesPerReplica},\"min\":${var.dns_proportional_autoscaler_minReplica}}}",
                     "--logtostderr=true",
                     "--v=2" ]
          volume_mount {
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
            name       = kubernetes_service_account.dns_proportional_autoscaler[0].default_secret_name
            read_only  = true
          }
        }
        volume {
          name = kubernetes_service_account.dns_proportional_autoscaler[0].default_secret_name

          secret {
            secret_name = kubernetes_service_account.dns_proportional_autoscaler[0].default_secret_name
          }
        }
        service_account_name = kubernetes_service_account.dns_proportional_autoscaler[0].metadata[0].name
      }
    }
  }
}

# ServiceAccount and RBAC configuration 
resource "kubernetes_service_account" "dns_proportional_autoscaler" {
  count = var.dns_proportional_autoscaler_enabled ? 1 : 0
  metadata {
    name      = "dns-proportional-autoscaler"
    namespace = "kube-system"
  }
  automount_service_account_token = true # terraform k8s provider default is false, which is the opposite of k8s!
}

resource "kubernetes_cluster_role" "dns_proportional_autoscaler" {
  count = var.dns_proportional_autoscaler_enabled ? 1 : 0
  metadata {
    name = "dns-proportional-autoscaler"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["replicationcontrollers/scale"]
    verbs      = ["get", "update"]
  }
  rule {
    api_groups = ["extensions", "apps"]
    resources  = ["deployments/scale", "replicasets/scale"]
    verbs      = ["get", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "create"]
  }
}

resource "kubernetes_cluster_role_binding" "dns_proportional_autoscaler" {
  count = var.dns_proportional_autoscaler_enabled ? 1 : 0
  metadata {
    name = "dns-proportional-autoscaler"
  }

  subject {
    // https://github.com/terraform-providers/terraform-provider-kubernetes/issues/204
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dns_proportional_autoscaler[0].metadata[0].name
    namespace = "kube-system"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.dns_proportional_autoscaler[0].metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}

