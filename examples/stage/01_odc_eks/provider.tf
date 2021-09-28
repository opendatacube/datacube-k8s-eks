provider "aws" {
  region                 = local.region
  max_retries            = 10
  skip_region_validation = true
}

provider "aws" {
  alias       = "cognito-region"
  region      = local.cognito_region
  max_retries = 10
}

# provider for cloudfront distribution certificate - this must be in us-east-1 to work with cloudfront
provider "aws" {
  alias       = "use1"
  region      = "us-east-1"
  max_retries = 10
}