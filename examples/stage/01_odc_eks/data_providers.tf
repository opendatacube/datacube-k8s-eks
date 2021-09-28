locals {
  region      = "af-south-1"
  owner       = "odc-test"
  namespace   = "odc-test"
  environment = "devtest"

  domain_name       = "devtest.digitalearth.africa"
  sandbox_host_name = "sandbox.${local.domain_name}"

  # ACM - used by ALB.
  # To create a new cert, set this flag to true
  create_certificate = true

  cognito_region           = "us-west-2"
  cognito_user_pool_name   = "${local.namespace}-${local.environment}-eks-userpool"
  cognito_user_pool_domain = "${local.namespace}-${local.environment}-eks-auth"

  # DB config
  db_name           = "odctest"
  db_engine_version = { postgres = "11.5" }
  db_multi_az       = false
}
