data "terraform_remote_state" "odc_eks-stage" {
  backend = "s3"
  config = {
    bucket = "odc-test-stage-backend-tfstate"
    key    = "odc_eks_terraform.tfstate"
    region = "ap-southeast-2"
  }
}

locals {
  region = data.terraform_remote_state.odc_eks-stage.outputs.region
  owner        = data.terraform_remote_state.odc_eks-stage.outputs.owner
  cluster_name = data.terraform_remote_state.odc_eks-stage.outputs.cluster_id
  namespace = data.terraform_remote_state.odc_eks-stage.outputs.namespace
  environment = data.terraform_remote_state.odc_eks-stage.outputs.environment
  domain_name = data.terraform_remote_state.odc_eks-stage.outputs.domain_name
  certificate_arn = data.terraform_remote_state.odc_eks-stage.outputs.certificate_arn
}

data "aws_caller_identity" "current" {
}