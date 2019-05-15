# Cluster config
region = "ap-southeast-2"

owner = "deacepticons"

cluster_name = "dev-eks-datacube"

admin_ip_addresses = "0.0.0.0/0"

# Data Orchestration
bucket = "dea-public-data"

services = ["ows"]

topic_arn = "arn:aws:sns:ap-southeast-2:538673716275:DEANewData"

# Cloudfront CDN
cloudfront_enabled = true

cached_app_domain = "*.services"

app_zone = "dev.dea.ga.gov.au"

custom_aliases = []

cloudfront_log_bucket = "dea-cloudfront-logs-dev.s3.amazonaws.com"

# Worker instances - General Node
default_worker_instance_type = "m4.large"

min_nodes_per_az = 1

max_nodes_per_az = 6

# Worker instances - Spot Nodes
spot_nodes_enabled = false

min_spot_nodes_per_az = 0

max_spot_nodes_per_az = 6

max_spot_price = "0.30"

# Worker instances - Dask Nodes
dask_nodes_enabled = false

min_dask_spot_nodes_per_az = 0

max_dask_spot_nodes_per_az = 6

max_dask_spot_price = "0.30"

# Database config

db_dns_name = "db"

db_dns_zone = "internal"

db_multi_az = true

# Addons - Kubernetes logs to cloudwatch

cloudwatch_logging_enabled = true

cloudwatch_log_group = "datakube"

cloudwatch_log_retention = 90

# Addons - Flux

flux_enabled = true
