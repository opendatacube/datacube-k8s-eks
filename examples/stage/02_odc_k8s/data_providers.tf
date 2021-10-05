data "terraform_remote_state" "odc_eks-stage" {
  backend = "s3"
  config = {
    bucket                 = "odc-test-devtest-backend-tfstate"
    key                    = "odc_eks_terraform.tfstate"
    region                 = "af-south-1"
    skip_region_validation = true
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id #data.aws_eks_cluster.cluster.id
}

locals {
  region      = data.terraform_remote_state.odc_eks-stage.outputs.region
  owner       = data.terraform_remote_state.odc_eks-stage.outputs.owner
  namespace   = data.terraform_remote_state.odc_eks-stage.outputs.namespace
  environment = data.terraform_remote_state.odc_eks-stage.outputs.environment

  cluster_id      = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id
  domain_name     = data.terraform_remote_state.odc_eks-stage.outputs.domain_name
  certificate_arn = data.terraform_remote_state.odc_eks-stage.outputs.certificate_arn

  db_hostname       = data.terraform_remote_state.odc_eks-stage.outputs.db_hostname
  db_admin_username = data.terraform_remote_state.odc_eks-stage.outputs.db_admin_username
  db_admin_password = data.terraform_remote_state.odc_eks-stage.outputs.db_admin_password
}

data "aws_caller_identity" "current" {
}
