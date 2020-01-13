terraform {
  backend "s3" {
    bucket = "odc-test-stage-backend-tfstate"
    key    = "odc_k8s_core_terraform.tfstate"
    region = "ap-southeast-2"
  }
}