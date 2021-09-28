module "cognito_auth" {
  # source = "github.com/opendatacube/datacube-k8s-eks//cognito?ref=master"
  source = "../../../cognito"

  providers = {
    aws = aws.cognito-region
  }

  auto_verify      = false
  user_pool_name   = local.cognito_user_pool_name
  user_pool_domain = local.cognito_user_pool_domain
  user_groups = {
    "dev-group" = {
      "description" = "Group defines dev users"
      "precedence"  = 5
    },
    "internal-group" = {
      "description" = "Group defines internal users"
      "precedence"  = 6
    },
    "trusted-group" = {
      "description" = "Group defines trusted users"
      "precedence"  = 7
    },
    "default-group" = {
      "description" = "Group defines default users"
      "precedence"  = 10
    }
  }
  app_clients = {
    "sandbox-client" = {
      "callback_urls" = [
        "https://${local.sandbox_host_name}/oauth_callback",
        "https://${local.sandbox_host_name}"
      ]
      "logout_urls"          = ["https://${local.sandbox_host_name}"]
      "default_redirect_uri" = "https://${local.sandbox_host_name}"
      "explicit_auth_flows"  = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_CUSTOM_AUTH"]
      "token_validity_units" = {
        access_token  = "days"
        id_token      = "days"
        refresh_token = "days"
      }
      "allowed_oauth_scopes"   = ["email", "aws.cognito.signin.user.admin", "openid"]
      "allowed_oauth_flows"    = ["code"]
      "access_token_validity"  = 1
      "id_token_validity"      = 1
      "refresh_token_validity" = 30
    },
  }

  admin_create_user_config = {
    allow_admin_create_user_only = true
    unused_account_validity_days = 0
    email_message                = <<EOT
Dear {username},

Welcome to Open Data Cube Sandbox.

Your username is {username} and temporary password is {####}.

When you first login you will be asked to enter a new password.
The temporary password will expire in 7 days.

If you have any difficulties please contact us.

Regards
Open Datacube Team
EOT
    email_subject                = "Your temporary password for Open Data Cube Sandbox - environment"
    sms_message                  = <<EOT
Welcome to Open Data Cube Sandbox.
Your username is {username} and temporary password is {####}.
EOT
  }

  # Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment
}
