provider "aws" {
  region      = "ap-southeast-2"
  max_retries = 10
}

provider "aws" {
  alias       = "cognito-region"
  region      = "ap-southeast-2"
  max_retries = 10
}

# provider for cloudfront distribution certificate - this must be in us-east-1 to work with cloudfront
provider "aws" {
  alias       = "use1"
  region      = "us-east-1"
  max_retries = 10
}
