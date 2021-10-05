data "terraform_remote_state" "odc_eks-stage" {
  backend = "s3"
  config = {
    bucket                 = "odc-test-devtest-backend-tfstate"
    key                    = "odc_eks_terraform.tfstate"
    region                 = "af-south-1"
    skip_region_validation = true
  }
}

data "terraform_remote_state" "odc_k8s-stage" {
  backend = "s3"
  config = {
    bucket                 = "odc-test-devtest-backend-tfstate"
    key                    = "odc_k8s_terraform.tfstate"
    region                 = "af-south-1"
    skip_region_validation = true
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
  name = "/${local.cluster_id}/ows_ro/db.creds"
}

locals {
  region      = data.terraform_remote_state.odc_eks-stage.outputs.region
  owner       = data.terraform_remote_state.odc_eks-stage.outputs.owner
  namespace   = data.terraform_remote_state.odc_eks-stage.outputs.namespace
  environment = data.terraform_remote_state.odc_eks-stage.outputs.environment

  cluster_id      = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id
  domain_name     = data.terraform_remote_state.odc_eks-stage.outputs.domain_name
  certificate_arn = data.terraform_remote_state.odc_eks-stage.outputs.certificate_arn

  node_security_group = data.terraform_remote_state.odc_eks-stage.outputs.node_security_group

  #EKS service account variables
  oidc_arn = data.terraform_remote_state.odc_k8s-stage.outputs.oidc_arn
  oidc_url = data.terraform_remote_state.odc_k8s-stage.outputs.oidc_url

  db_hostname = data.terraform_remote_state.odc_eks-stage.outputs.db_hostname
  db_port     = "5432"

  ows_db_name        = "ows"
  ows_db_ro_username = element(split(":", data.aws_ssm_parameter.ows_db_ro_creds.value), 0)
  ows_db_ro_password = element(split(":", data.aws_ssm_parameter.ows_db_ro_creds.value), 1)
}

data "aws_caller_identity" "current" {
}
