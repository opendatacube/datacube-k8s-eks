provider "aws" {
  region      = data.terraform_remote_state.odc_eks-stage.outputs.region
  max_retries = 10
}