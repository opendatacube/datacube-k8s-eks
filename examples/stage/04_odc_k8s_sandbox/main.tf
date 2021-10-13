terraform {
  backend "s3" {
    bucket = "odc-test-devtest-backend-tfstate"
    key    = "odc_k8s_sandbox_terraform.tfstate"
    region = "ap-southeast-2"
  }
}
