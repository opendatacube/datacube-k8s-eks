provider "aws" {
  region      = local.region
  max_retries = 10
}