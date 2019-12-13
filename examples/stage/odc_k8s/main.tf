terraform {
  backend "remote" {
    organization = "A TF Cloud Org"

    workspaces {
      name = "odc_k8s-stage-TF_CLOUD_WORKSPACE"
    }
  }
}