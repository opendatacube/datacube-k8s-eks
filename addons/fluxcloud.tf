variable "fluxcloud_enabled" {
  default = false
}

variable "fluxcloud_slack_url" {
  type        = "string"
  description = "Slack webhook URL for fluxcloud to use"
  default     = ""
}

variable "fluxcloud_slack_channel" {
  type        = "string"
  description = "Slack channel for fluxcloud to use"
  default     = ""
}

variable "fluxcloud_slack_name" {
  type        = "string"
  description = "Slack name for fluxcloud to post under"
  default     = ""
}

variable "fluxcloud_slack_emoji" {
  type        = "string"
  description = "Slack emoji for fluxcloud to post under"
  default     = ""
}

variable "fluxcloud_github_url" {
  type        = "string"
  description = "VCS URL for fluxcloud links in messages, does not have to be a GitHub URL"
  default     = ""
}

variable "fluxcloud_commit_template" {
  type        = "string"
  description = "VCS template for fluxcloud links in messages, default is for GitHub"
  default     = "{{ .VCSLink }}/commit/{{ .Commit }}"
}

resource "kubernetes_service" "fluxcloud" {
  count = var.fluxcloud_enabled ? 1 : 0
  metadata {
    name = "fluxcloud"
  }

  spec {
    selector = {
      name = "fluxcloud"
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "3032"
    }
  }
}

resource "kubernetes_deployment" "fluxcloud" {
  count = var.fluxcloud_enabled ? 1 : 0
  metadata {
    name = "fluxcloud"
  }

  spec {
    replicas = 1
    
    selector {
      match_labels = {
        name = "fluxcloud"
      }
    }

    template {
      metadata {
        labels = {
          name = "fluxcloud"
        }
      }

      spec {
        container {
          name  = "fluxcloud"
          image = "justinbarrick/fluxcloud:v0.3.8"

          port {
            container_port = 3032
          }

          env {
            name  = "SLACK_URL"
            value = var.fluxcloud_slack_url
          }

          env {
            name  = "SLACK_CHANNEL"
            value = var.fluxcloud_slack_channel
          }

          env {
            name  = "GITHUB_URL"
            value = var.fluxcloud_github_url
          }

          env {
            name  = "LISTEN_ADDRESS"
            value = ":3032"
          }

          env {
            name  = "SLACK_USERNAME"
            value = var.fluxcloud_slack_name
          }

          env {
            name  = "SLACK_ICON_EMOJI"
            value = var.fluxcloud_slack_emoji
          }

          env {
            name  = "COMMIT_TEMPLATE"
            value = var.fluxcloud_commit_template
          }

          image_pull_policy = "IfNotPresent"
        }
      }
    }

    strategy {
      type = "Recreate"
    }
  }
}
