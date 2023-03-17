variable "cluster_id" {
  default = "terraform-eks"
  type    = string
}

variable "cluster_version" {
  description = "EKS Version to use with this cluster"
}

variable "admin_access_CIDRs" {
  description = "Locks ssh and api access to these IPs"
  type        = map(string)
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to place EKS in"
}

variable "eks_subnet_ids" {
  type        = list(string)
  description = "List of subnets to place EKS workers in"
}

variable "enable_ec2_ssm" {
  default     = true
  description = "Enables the IAM policy required for AWS EC2 System Manager."
}

variable "user_custom_policy" {
  description = "The IAM custom policy to create and attach to EKS user role"
  type        = string
  default     = ""
}

variable "user_additional_policy_arn" {
  description = "The list of pre-defined IAM policy required to EKS user role"
  type        = list(string)
  default     = []
}

# Worker variables
variable "ami_image_id" {
  default     = ""
  description = "Overwrites the default ami (latest Amazon EKS)"
}

variable "node_group_name" {
  default = "eks"
}

variable "default_worker_instance_type" {
}

variable "min_nodes" {
  default = 0
}

variable "desired_nodes" {
  default = 0
}

variable "max_nodes" {
  default = 0
}

variable "spot_nodes_enabled" {
  default = false
}

variable "min_spot_nodes" {
  default = 0
}

variable "max_spot_nodes" {
  default = 0
}

variable "max_spot_price" {
  default = "0.40"
}

variable "volume_size" {
  default = 20
}

variable "volume_type" {
  default     = ""
  type        = string
  description = "Override EBS volume type e.g. gp2, gp3"
}

variable "spot_volume_size" {
  default = 20
}

variable "extra_kubelet_args" {
  type        = string
  description = "Additional kubelet command-line arguments (e.g. '--arg1=value --arg2')"
  default     = ""
}

variable "extra_bootstrap_args" {
  type        = string
  description = "Additional bootstrap.sh command-line arguments (e.g. '--arg1=value --arg2')"
  default     = ""
}

variable "extra_userdata" {
  type        = string
  description = "Additional EC2 user data commands that will be passed to EKS nodes"
  default     = <<USERDATA
echo ""
USERDATA

}

variable "enabled_cluster_log_types" {
  type        = list(string)
  description = "Enable EKS control plane logging to CloudWatch"
  default     = []
}

variable "enable_custom_cluster_log_group" {
  type        = bool
  description = "Create a custom CloudWatch Log Group for the cluster. Note that if you supply enabled_cluster_log_types and leave this false, EKS will create a log group automatically with default retention values."
  default     = false
}

variable "log_retention_period" {
  type        = number
  description = "Retention period in days of enabled EKS cluster logs"
  default     = 30
}

#--------------------------------------------------------------
# Tags
#--------------------------------------------------------------
variable "environment" {
}

variable "namespace" {
}

variable "owner" {
}

variable "tags" {
  type        = map(string)
  description = "Additional tags (e.g. `map('StackName','XYZ')`"
  default     = {}
}

variable "wait_for_cluster_cmd" {
  description = "Custom local-exec command to execute for determining if the eks cluster is healthy. Cluster endpoint will be available as an environment variable called ENDPOINT"
  type        = string
  default     = "for i in `seq 1 60`; do if `command -v wget > /dev/null`; then wget --no-check-certificate -O - -q $ENDPOINT/healthz >/dev/null && exit 0 || true; else curl -k -s $ENDPOINT/healthz >/dev/null && exit 0 || true;fi; sleep 5; done; echo TIMEOUT && exit 1"
}

variable "wait_for_cluster_interpreter" {
  description = "Custom local-exec command line interpreter for the command to determining if the eks cluster is healthy."
  type        = list(string)
  default     = ["/bin/sh", "-c"]
}

variable "node_extra_tags" {
  type        = map(string)
  description = "Additional tags for EKS nodes (e.g. `map('StackName','XYZ')`"
  default     = {}
}

variable "metadata_options" {
  description = "Metadata options for the EKS node launch templates. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#metadata-options"
  type        = object(any)
  default     = {}
}