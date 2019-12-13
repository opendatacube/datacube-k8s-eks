terraform {
  backend "remote" {
    organization = "A TF Cloud Org"

    workspaces {
      name = "odc_eks-stage-A_TF_CLOUD_WORKSPACE"
    }
  }
}