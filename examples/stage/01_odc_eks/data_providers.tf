locals {
  region      = "ap-southeast-2"
  owner       = "odc-test"
  namespace   = "odc-test"
  environment = "stage"

  domain_name       = "stage.dea.ga.gov.au"
  sandbox_host_name = "app.${local.domain_name}"

  # ACM - used by ALB.
  # To create a new cert, set this flag to true
  create_certificate = false

  # DB config
  db_name           = "odctest"
  db_engine_version = { postgres = "11.5" }
  db_multi_az       = false
}
