data "terraform_remote_state" "odc_eks-stage" {
  backend = "s3"
  config = {
    bucket = "odc-test-stage-backend-tfstate"
    key    = "odc_eks_terraform.tfstate"
    region = "ap-southeast-2"
  }
}

data "terraform_remote_state" "odc_k8s-stage" {
  backend = "s3"
  config = {
    bucket = "odc-test-stage-backend-tfstate"
    key    = "odc_k8s_terraform.tfstate"
    region = "ap-southeast-2"
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id
}

# NOTE: read OWS db reader creds from parameter store
#   check examples/scripts/init_ows_db.sh script for reference
data "aws_ssm_parameter" "ows_db_ro_creds" {
  count = local.db_enabled ? 1 : 0
  name  = "/${local.cluster_id}/ows_reader/db.creds"
}

locals {
  region      = data.terraform_remote_state.odc_eks-stage.outputs.region
  owner       = data.terraform_remote_state.odc_eks-stage.outputs.owner
  namespace   = data.terraform_remote_state.odc_eks-stage.outputs.namespace
  environment = data.terraform_remote_state.odc_eks-stage.outputs.environment
  tags        = data.terraform_remote_state.odc_eks-stage.outputs.tags

  cluster_id      = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id
  domain_name     = data.terraform_remote_state.odc_eks-stage.outputs.domain_name
  certificate_arn = data.terraform_remote_state.odc_eks-stage.outputs.certificate_arn

  node_security_group = data.terraform_remote_state.odc_eks-stage.outputs.node_security_group

  #EKS service account variables
  oidc_arn = data.terraform_remote_state.odc_k8s-stage.outputs.oidc_arn
  oidc_url = data.terraform_remote_state.odc_k8s-stage.outputs.oidc_url

  cognito_region                              = data.terraform_remote_state.odc_eks-stage.outputs.cognito_region
  cognito_auth_userpool_id                    = data.terraform_remote_state.odc_eks-stage.outputs.cognito_auth_userpool_id
  cognito_auth_userpool_arn                   = data.terraform_remote_state.odc_eks-stage.outputs.cognito_auth_userpool_arn
  cognito_auth_userpool_domain                = data.terraform_remote_state.odc_eks-stage.outputs.cognito_auth_userpool_domain
  cognito_auth_userpool_grafana_client_id     = data.terraform_remote_state.odc_eks-stage.outputs.cognito_auth_userpool_grafana_client_id
  cognito_auth_userpool_grafana_client_secret = data.terraform_remote_state.odc_eks-stage.outputs.cognito_auth_userpool_grafana_client_secret

  db_enabled = data.terraform_remote_state.odc_eks-stage.outputs.db_enabled

  db_hostname = data.terraform_remote_state.odc_eks-stage.outputs.db_hostname
  db_port     = "5432"

  ows_db_name        = data.terraform_remote_state.odc_eks-stage.outputs.db_name
  ows_db_ro_username = local.db_enabled ? element(split(":", data.aws_ssm_parameter.ows_db_ro_creds[0].value), 0) : ""
  ows_db_ro_password = local.db_enabled ? element(split(":", data.aws_ssm_parameter.ows_db_ro_creds[0].value), 1) : ""
}

data "aws_caller_identity" "current" {
}
