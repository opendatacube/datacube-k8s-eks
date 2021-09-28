terraform {
  backend "s3" {
    bucket = "odc-test-devtest-backend-tfstate"
    key    = "odc_k8s_terraform.tfstate"
    region = "af-south-1"
  }
}
