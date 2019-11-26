# BITNAMI KUBEWATCH CONTAINER HELM CHARTS
# =======================================

variable "kubewatch_enabled" {
  description = "Kubewatch flag when enabled shall alert Slack about helm activities"
  type        = bool
  default     = false
}

variable "kubewatch_slack_enabled" {
  description = "Push notification to Slack channel using slack token"
  type        = bool
  default     = false
}

variable "kubewatch_slack_channel" {
  description = "Slack channel to notify"
  type        = string
  default     = ""
}

variable "kubewatch_slack_token" {
  description = "Slack bots token. Create using: https://my.slack.com/services/new/bot and invite the bot to your channel using: /join @botname"
  type        = string
  default     = ""
}

variable "kubewatch_hipchat_enabled" {
  description = "Push notification to hipchat room"
  type        = bool
  default     = false
}

variable "kubewatch_hipchat_room" {
  type        = string
  default     = ""
}

variable "kubewatch_hipchat_token" {
  type        = string
  default     = ""
}

variable "kubewatch_hipchat_url" {
  type        = string
  default     = ""
}

variable "kubewatch_mattermost_enabled" {
  description = "Push notification to mattermost"
  type        = bool
  default     = false
}

variable "kubewatch_mattermost_channel" {
  type        = string
  default     = ""
}

variable "kubewatch_mattermost_url" {
  type        = string
  default     = ""
}

variable "kubewatch_mattermost_username" {
  type        = string
  default     = ""
}

variable "kubewatch_flock_enabled" {
  description = "Push notification to flock"
  type        = bool
  default     = false
}

variable "kubewatch_flock_url" {
  type        = string
  default     = ""
}

variable "kubewatch_webhook_enabled" {
  description = "Push notification to Webhook URL"
  type        = bool
  default     = false
}

variable "kubewatch_webhook_url" {
  type        = string
  default     = ""
}

variable "kubewatch_resourcesToWatch_deployment" {
  description = "Monitor k8s deployments"
  type        = bool
  default     = false
}

variable "kubewatch_resourcesToWatch_replicationcontroller" {
  description = "Monitor k8s Replication Controller"
  type        = bool
  default     = false
}

variable "kubewatch_resourcesToWatch_replicaset" {
  description = "Monitor k8s Replica Set"
  type        = bool
  default     = false
}

variable "kubewatch_resourcesToWatch_daemonset" {
  description = "Monitor k8s Daemon Set"
  type        = bool
  default     = false
}

variable "kubewatch_resourcesToWatch_services" {
  description = "Monitor k8s Services"
  type        = bool
  default     = false
}

variable "kubewatch_resourcesToWatch_pod" {
  description = "Monitor k8s Pods"
  type        = bool
  default     = false
}

variable "kubewatch_resourcesToWatch_job" {
  description = "Monitor k8s Jobs"
  type        = bool
  default     = false
}

variable "kubewatch_resourcesToWatch_persistentvolume" {
  description = "Monitor k8s Persistent Volume"
  type        = bool
  default     = false
}

resource "kubernetes_namespace" "monitoring" {
  count = var.kubewatch_enabled ? 1 : 0

  metadata {
    name = "monitoring"

    labels = {
      managed-by = "Terraform"
    }
  }
}

# Create the kubewatch operator
resource "helm_release" "kubewatch_operator" {
  count      = var.kubewatch_enabled ? 1 : 0
  name       = "kubewatch"
  repository = "stable"
  chart      = "kubewatch"
  namespace  = "monitoring"

  set {
    name  = "slack.enabled"
    value = (var.kubewatch_slack_enabled != "") ? var.kubewatch_slack_enabled : false
  }

  set {
    name  = "slack.channel"
    value = (var.kubewatch_slack_enabled != "") ? var.kubewatch_slack_channel : ""
  }

  set {
    name  = "slack.token"
    value = (var.kubewatch_slack_enabled != "") ? var.kubewatch_slack_token : ""
  }

  set {
    name  = "hipchat.enabled"
    value = (var.kubewatch_hipchat_enabled != "") ? var.kubewatch_hipchat_enabled : ""
  }

  set {
    name  = "hipchat.room"
    value = (var.kubewatch_hipchat_enabled != "") ? var.kubewatch_hipchat_room : ""
  }

  set {
    name  = "hipchat.token"
    value = (var.kubewatch_hipchat_enabled != "") ? var.kubewatch_hipchat_token : ""
  }

  set {
    name  = "hipchat.url"
    value = (var.kubewatch_hipchat_enabled != "") ? var.kubewatch_hipchat_url : ""
  }

  set {
    name  = "mattermost.enabled"
    value = (var.kubewatch_mattermost_enabled != "") ? var.kubewatch_mattermost_enabled : ""
  }

  set {
    name  = "mattermost.channel"
    value = (var.kubewatch_mattermost_enabled != "") ? var.kubewatch_mattermost_channel : ""
  }

  set {
    name  = "mattermost.url"
    value = (var.kubewatch_mattermost_enabled != "") ? var.kubewatch_mattermost_url : ""
  }

  set {
    name  = "mattermost.username"
    value = (var.kubewatch_mattermost_enabled != "") ? var.kubewatch_mattermost_username : ""
  }

  set {
    name  = "flock.enabled"
    value = (var.kubewatch_flock_enabled != "") ? var.kubewatch_flock_enabled : ""
  }

  set {
    name  = "flock.url"
    value = (var.kubewatch_flock_enabled != "") ? var.kubewatch_flock_url : ""
  }

  set {
    name  = "webhook.enabled"
    value = (var.kubewatch_webhook_enabled != "") ? var.kubewatch_webhook_enabled : ""
  }

  set {
    name  = "webhook.url"
    value = (var.kubewatch_webhook_enabled != "") ? var.kubewatch_webhook_url : ""
  }

  set {
    name  = "resourcesToWatch.deployment"
    value = (var.kubewatch_enabled != "") ? var.kubewatch_resourcesToWatch_deployment : false
  }

  set {
    name  = "resourcesToWatch.replicationcontroller"
    value = (var.kubewatch_enabled != "") ? var.kubewatch_resourcesToWatch_replicationcontroller : false
  }

  set {
    name  = "resourcesToWatch.replicaset"
    value = (var.kubewatch_enabled != "") ? var.kubewatch_resourcesToWatch_replicaset : false
  }

  set {
    name  = "resourcesToWatch.daemonset"
    value = (var.kubewatch_enabled != "") ? var.kubewatch_resourcesToWatch_daemonset : false
  }

  set {
    name  = "resourcesToWatch.services"
    value = (var.kubewatch_enabled != "") ? var.kubewatch_resourcesToWatch_services : false
  }

  set {
    name  = "resourcesToWatch.pod"
    value = (var.kubewatch_enabled != "") ? var.kubewatch_resourcesToWatch_pod : false
  }

  set {
    name  = "resourcesToWatch.job"
    value = (var.kubewatch_enabled != "") ? var.kubewatch_resourcesToWatch_job : false
  }

  set {
    name  = "resourcesToWatch.persistentvolume"
    value = (var.kubewatch_enabled != "") ? var.kubewatch_resourcesToWatch_persistentvolume : false
  }

  depends_on = [
    kubernetes_namespace.monitoring,
    kubernetes_service_account.tiller,
    kubernetes_cluster_role_binding.tiller_clusterrolebinding,
    null_resource.helm_init_client
    ]

}
