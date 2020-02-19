locals {
  region      = "ap-southeast-2"
  owner       = "odc-test"
  namespace   = "odc-test"
  environment = "stage"
}

module "odc_cluster_label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.4.0"
  namespace  = local.namespace
  stage      = local.environment
  name      = "eks"
  delimiter  = "-"
}

module "odc_eks" {
  # source = "github.com/opendatacube/datacube-k8s-eks//odc_eks?ref=terraform-aws-odc"
  source = "../../../odc_eks"

  # Cluster config
  region          = local.region
  cluster_id      = module.odc_cluster_label.id   # optional - if not provided it uses odc_eks_label defined in the module.
  cluster_version = 1.14

  owner           = local.owner
  namespace       = local.namespace
  environment     = local.environment

  admin_access_CIDRs = {
    "Everywhere" = "0.0.0.0/0"
  }

  domain_name = "test.dea.ga.gov.au"

  # ACM - used by ALB
  create_certificate  = false

  # DB config
  db_name = "odctest"
  db_engine_version = { postgres = "11.5" }
  db_multi_az = false

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
}
