# Cluster config
owner = "datakube-owner"

cluster_name = "dev-eks-datacube"

cluster_version = "1.13"

admin_access_CIDRs = {
  "Everywhere" = "0.0.0.0/0"
}

# Worker instances
default_worker_instance_type = "m4.large"

spot_nodes_enabled = false

min_nodes_per_az = 1

desired_nodes_per_az = 1

max_nodes_per_az = 2

max_spot_price = "0.4"

# Database config

db_multi_az = false

# Addons - Kubernetes logs to cloudwatch

cloudwatch_logs_enabled = false

cloudwatch_log_group = "datakube"

cloudwatch_log_retention = 90

alb_ingress_enabled = true
