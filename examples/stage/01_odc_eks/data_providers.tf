locals {
  region      = "ap-southeast-2"
  owner       = "odc-test"
  namespace   = "odc-test"
  environment = "stage"

  cluster_version = 1.18

  domain_name       = "test.odc.gov.au" # Replace to your domain
  sandbox_host_name = "sandbox.${local.domain_name}"

  # ACM - used by ALB.
  # To create a new wildcard cert for given domain_name, set this flag to true
  # NOTE: make sure hosted zone is pre-provisined in Route53 for DNS validation
  create_certificate = true
  cf_enable          = false
  waf_enable         = false

  cognito_region           = local.region
  cognito_user_pool_name   = "${local.namespace}-${local.environment}-eks-userpool"
  cognito_user_pool_domain = "${local.namespace}-${local.environment}-eks-auth"

  # DB config
  db_enabled        = true
  db_name           = "odc"
  db_engine_version = { postgres = "12.5" }
  db_instance_type  = "db.m5.xlarge"
  db_multi_az       = false

  # provide organisation tags
  tags = {}
}
