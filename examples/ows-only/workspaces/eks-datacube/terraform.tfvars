# Cluster config
# ==============
# Change this region depending on where your data is located
region = "ap-southeast-2"

# This is a tag that will be put on resources
owner = "info@opendatacube.org"

# This should match your workspace name
cluster_name = "eks-datacube"
cluster_version = "1.13"
admin_access_CIDRs = {
  "Everywhere" = "0.0.0.0/0"
}

# You'll need to modify this to users that exist in your AWS Account
users = [
  "user/jdoe",
]

# Cloudfront CDN Config 
# =====================
cf_enable = false
cf_dns_record = "ows"
cf_origin_dns_record = "cached-alb"
cf_custom_aliases = []
cf_certificate_arn = ""
cf_certificate_create = false

# This will need to be modified to a bucket that exists in your account
cf_log_bucket = "dea-cloudfront-logs-dev.s3.amazonaws.com"
cf_log_bucket_create = false

# Worker instances 
# ================
# r4.4xlarges are good for production workloads due to their high network bandwidth
default_worker_instance_type = "r4.4xlarge"

# Spot instances are great for non-user facing workloads like running Dask jobs
spot_nodes_enabled = true
max_spot_price = "0.8"

# The number of instances will be nodes_per_az * number of az's
min_nodes_per_az = 0
max_nodes_per_az = 2

# desired is only for initial deployment, it will be ignored afterwards
desired_nodes_per_az = 1

# production workloads should use multi_az
db_multi_az = false

# we store the credentials so they can be accessed by apps
store_db_credentials = true

# Addons
alb_ingress_enabled = true
cloudwatch_logs_enabled = true
cluster_autoscaler_enabled = true
datacube_wms_enabled = true
datacube_wps_enabled = true
domain_name = "dea.ga.gov.au"
external_dns_enabled = true
flux_enabled = true
metrics_server_enabled = true
prometheus_enabled = true
fluxcloud_enabled = true

# Flux
# ====
flux_git_repo_url = "git@xxx.xxx:xxxx/xxxx.git"
flux_git_branch = "eks-datacube"
flux_git_label = "eks-datacube-flux"
fluxcloud_slack_url = "https://hooks.slack.com/services/xxxxxxx"
fluxcloud_slack_channel = "#flux-notifications"
fluxcloud_slack_name = "Flux datacube Deployer"
fluxcloud_slack_emoji = ":metal:"
fluxcloud_github_url = "https://xxxx.xxxx/xxxx/xxxxxx"
fluxcloud_commit_template = "{{ .VCSLink }}/commits/{{ .Commit }}"
