# Cluster config
region = "ap-southeast-2"

owner = "deacepticons"

cluster_name = "dev-eks-datacube"

admin_access_CIDRs = {
  "Everywhere" = "0.0.0.0/0"
}

# Data Orchestration
bucket = "dea-public-data"

services = ["ows"]

topic_arn = "arn:aws:sns:ap-southeast-2:538673716275:DEANewData"

# Cloudfront CDN
cloudfront_enabled = false

cached_app_domain = "services"

app_zone = "dev.dea.ga.gov.au"

custom_aliases = []

cloudfront_log_bucket = "dea-cloudfront-logs-dev.s3.amazonaws.com"

create_certificate = true

# Worker instances

default_worker_instance_type = "m4.large"

spot_nodes_enabled = false

min_nodes_per_az = 1

desired_nodes_per_az = 1

max_nodes_per_az = 2

max_spot_price = "0.4"

# Database config

db_dns_name = "db"

db_dns_zone = "internal"

db_multi_az = false

# Addons - Kubernetes logs to cloudwatch

cloudwatch_logs_enabled = true

cloudwatch_log_group = "datakube"

cloudwatch_log_retention = 90

alb_ingress_enabled = true
