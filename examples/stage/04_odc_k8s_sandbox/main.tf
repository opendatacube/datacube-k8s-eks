terraform {
  backend "s3" {
    bucket = "odc-test-devtest-backend-tfstate"
    key    = "odc_k8s_apps_terraform.tfstate"
    region = "af-south-1"
  }
}
