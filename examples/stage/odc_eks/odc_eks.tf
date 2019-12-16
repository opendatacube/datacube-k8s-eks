module "odc_eks" {
  # source = "github.com/opendatacube/datacube-k8s-eks//odc_eks?ref=terraform-aws-odc"
  source = "../../../odc_eks"

  # Cluster config
  region = "ap-southeast-2"

  owner = "odc-test"
  namespace = "odc-test"
  environment = "stage"
  cluster_version = 1.13

  admin_access_CIDRs = {
    "Everywhere" = "0.0.0.0/0"
  }

  users = [
    "user/ngandhi",
  ]

  domain_name = "test.dea.ga.gov.au"

  # DB config
  db_name = "odctest"

  # System node instances
  #default_worker_instance_type = "m4.large"
  default_worker_instance_type = "t3.medium"
  spot_nodes_enabled = true
  min_nodes = 2
  max_nodes = 5

  # Cloudfront CDN
  cf_enable = false

  # WAF
  waf_enable             = false
  # waf_target_scope       = "regional"
  # waf_log_bucket_prefix  = "dea-waf-logs"  # creates a bucket: <waf_log_bucket_prefix>-<environment>
}
