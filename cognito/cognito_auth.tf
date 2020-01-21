# ======================================
# COGNITO

resource "aws_cognito_user_pool" "pool" {
  name = var.user_pool_name
  alias_attributes           = ["email"]
  auto_verified_attributes   = var.auto_verify ? ["email"] : null

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = false
    required            = true
    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    mutable             = true
    required            = true
    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
  }

  # Enable this if you want to prevent destroy
  # lifecycle {
  #   prevent_destroy = true
  # }

  tags = {
    Name        = var.user_pool_name
    Cluster     = var.cluster_id
    Owner       = var.owner
    Namespace   = var.namespace
    Environment = var.environment
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "client"
  user_pool_id = aws_cognito_user_pool.pool.id
  generate_secret     = true
  supported_identity_providers = ["COGNITO"]
  callback_urls =[var.callback_url]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = ["email", "aws.cognito.signin.user.admin", "openid"]
  allowed_oauth_flows = ["code"]
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain       = var.user_pool_domain
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_group" "group" {
  count        = length(var.user_groups)
  user_pool_id = aws_cognito_user_pool.pool.id
  name         = var.user_groups[count.index].name
  description  = var.user_groups[count.index].description
  precedence   = var.user_groups[count.index].precedence
}
