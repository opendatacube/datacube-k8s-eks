terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 3.13"
      configuration_aliases = [aws.us-east-1]
    }
  }
}