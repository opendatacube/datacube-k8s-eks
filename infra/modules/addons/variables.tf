variable "cluster_id" {
}

variable "cluster_api_endpoint" {
}

variable "cluster_ca" {
}

variable "cluster_arn" {
}

variable "domain_name" {
  description = "The domain name to be used by for applications deployed to the cluster and using ingress"
  type        = string
}

variable "owner" {
}

variable "external_dns_enabled" {
}

variable "txt_owner_id" {
} 

variable "cloudwatch_logs_enabled" {
}

variable "cloudwatch_log_group" {
}

variable "cloudwatch_log_retention" {
}

variable "alb_ingress_enabled" {
}

variable "prometheus_enabled" {
}

variable "cluster_autoscaler_enabled" {
}

variable "autoscaler-scale-down-unneeded-time" {
}

variable "metrics_server_enabled" {
}

variable "waf_environment" {
}

variable "dns_proportional_autoscaler_enabled" {
}

variable "dns_proportional_autoscaler_coresPerReplica" {
}

variable "dns_proportional_autoscaler_nodesPerReplica" {
}

variable "dns_proportional_autoscaler_minReplica" {
}

variable "custom_kube2iam_roles" {
}
