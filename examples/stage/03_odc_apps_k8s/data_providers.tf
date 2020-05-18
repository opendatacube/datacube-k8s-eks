data "terraform_remote_state" "odc_eks-stage" {
  backend = "s3"
  config = {
    bucket = "odc-test-stage-backend-tfstate"
    key    = "odc_eks_terraform.tfstate"
    region = "ap-southeast-2"
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id
}

# NOTE: read db creds from parameter store
data "aws_ssm_parameter" "ows_db_creds" {
  name = "/${local.cluster_id}/ows/db.creds"
}

locals {
  region              = data.terraform_remote_state.odc_eks-stage.outputs.region
  owner               = data.terraform_remote_state.odc_eks-stage.outputs.owner
  cluster_id          = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id
  namespace           = data.terraform_remote_state.odc_eks-stage.outputs.namespace
  environment         = data.terraform_remote_state.odc_eks-stage.outputs.environment
  domain_name         = data.terraform_remote_state.odc_eks-stage.outputs.domain_name
  certificate_arn     = data.terraform_remote_state.odc_eks-stage.outputs.certificate_arn
  node_security_group = data.terraform_remote_state.odc_eks-stage.outputs.node_security_group

  db_hostname = data.terraform_remote_state.odc_eks-stage.outputs.db_hostname
  db_port     = "5432"

  ows_db_name     = "ows"
  ows_db_username = element(split(":", data.aws_ssm_parameter.ows_db_creds.value), 0)
  ows_db_password = element(split(":", data.aws_ssm_parameter.ows_db_creds.value), 1)
}

data "aws_caller_identity" "current" {
}