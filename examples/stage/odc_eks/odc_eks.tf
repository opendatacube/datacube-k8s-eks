locals {
  region      = "ap-southeast-2"
  owner       = "odc-test"
  namespace   = "odc-test"
  environment = "stage"
}

module "odc_eks" {
  # source = "github.com/opendatacube/datacube-k8s-eks//odc_eks?ref=terraform-aws-odc"
  source = "../../../odc_eks"

  # Cluster config
  region          = local.region
  owner           = local.owner
  namespace       = local.namespace
  environment     = local.environment
  cluster_version = 1.13

  admin_access_CIDRs = {
    "Everywhere" = "0.0.0.0/0"
  }

  domain_name = "test.dea.ga.gov.au"

  # ACM - used by ALB
  create_certificate  = false

  # DB config
  db_name = "odctest"

  # System node instances
  #default_worker_instance_type = "m4.large"
  default_worker_instance_type = "t3.medium"
  spot_nodes_enabled = true
  min_nodes = 2
  max_nodes = 4

  # Cloudfront CDN
  cf_enable                 = false
  cf_dns_record             = "odc"
  cf_origin_dns_record      = "cached-alb"
  cf_custom_aliases         = []
  cf_certificate_create     = true
  cf_origin_protocol_policy = "https-only"
  cf_log_bucket_create      = true
  cf_log_bucket             = "${local.namespace}-${local.environment}-cloudfront-logs"

  # WAF
  waf_enable             = false
  waf_target_scope       = "regional"
  waf_log_bucket         = "${local.namespace}-${local.environment}-waf-logs"

  jhub_cognito_auth_enabled = false
  jhub_cognito_user_groups = [
    {
      name        = "dev-group"
      description = "Group defines Jupyterhub dev users"
      precedence  = 5
    },
    {
      name        = "internal-group"
      description = "Group defines Jupyterhub internal users"
      precedence  = 6
    },
    {
      name        = "trusted-group"
      description = "Group defines Jupyterhub trusted users"
      precedence  = 7
    },
    {
      name        = "default-group"
      description = "Group defines Jupyterhub default users"
      precedence  = 10
    }
  ]
}
