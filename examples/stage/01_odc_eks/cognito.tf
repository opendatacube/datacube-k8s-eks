module "cognito_auth" {
  # source = "github.com/opendatacube/datacube-k8s-eks//cognito?ref=master"
  source = "../../../cognito"

  auto_verify      = true
  user_pool_name   = "${module.odc_cluster_label.id}-userpool"
  user_pool_domain = "${module.odc_cluster_label.id}-auth"
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
      callback_urls = [
        "https://${local.sandbox_host_name}/oauth_callback",
        "https://${local.sandbox_host_name}"
      ]
      logout_urls = [
        "https://${local.sandbox_host_name}"
      ]
      default_redirect_uri = "https://${local.sandbox_host_name}"
      explicit_auth_flows = [
        "ALLOW_REFRESH_TOKEN_AUTH",
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_CUSTOM_AUTH"
      ]
    }
  }

  # Tags
  owner       = local.owner
  namespace   = local.namespace
  environment = local.environment
}