# ======================================
# COGNITO

variable "jhub_cognito_auth_enabled" {
  default = false
}

variable "jhub_callback_url" {
  default     = "https:///jhub.example.com/oauth_callback"
  description = "the callback url for your jhub application"
}

resource "aws_cognito_user_pool" "pool" {
  count = var.jhub_cognito_auth_enabled ? 1 : 0
  name = "${var.cluster_name}-jhub-userpool"
  alias_attributes           = ["email"]
  auto_verified_attributes   = ["email"]

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
    mutable             = false
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
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_cognito_user_pool_client" "client" {
  count = var.jhub_cognito_auth_enabled ? 1 : 0
  name = "client"
  user_pool_id = "${aws_cognito_user_pool.pool[0].id}"
  generate_secret     = true
  supported_identity_providers = ["COGNITO"]
  callback_urls =["${var.jhub_callback_url}"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = ["email", "aws.cognito.signin.user.admin", "openid"]
  allowed_oauth_flows = ["code"]
}

resource "aws_cognito_user_pool_domain" "main" {
  count = var.jhub_cognito_auth_enabled ? 1 : 0
  domain       = "${var.cluster_name}-jhub-auth"
  user_pool_id = "${aws_cognito_user_pool.pool[0].id}"
}

resource "aws_cognito_user_group" "dev_group" {
  name         = "dev-group"
  user_pool_id = "${aws_cognito_user_pool.pool[0].id}"
  description  = "Group defines Jupyterhub development users"
  precedence   = 32
}

resource "aws_cognito_user_group" "internal_group" {
  name         = "internal-group"
  user_pool_id = "${aws_cognito_user_pool.pool[0].id}"
  description  = "Group defines Jupyterhub internal users"
  precedence   = 42
}

resource "aws_cognito_user_group" "trusted_group" {
  name         = "trusted-group"
  user_pool_id = "${aws_cognito_user_pool.pool[0].id}"
  description  = "Group defines Jupyterhub trusted users"
  precedence   = 32
}

resource "aws_cognito_user_group" "default_group" {
  name         = "default-group"
  user_pool_id = "${aws_cognito_user_pool.pool[0].id}"
  description  = "Group defines Jupyterhub default users"
  precedence   = 42
}