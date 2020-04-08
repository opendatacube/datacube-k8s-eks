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

    # admin_create_user_config
  dynamic "admin_create_user_config" {
    for_each = local.admin_create_user_config
    content {
      allow_admin_create_user_only = lookup(admin_create_user_config.value, "allow_admin_create_user_only")
      unused_account_validity_days = lookup(admin_create_user_config.value, "unused_account_validity_days")

      dynamic "invite_message_template" {
        for_each = lookup(admin_create_user_config.value, "email_message", null) == null && lookup(admin_create_user_config.value, "email_subject", null) == null && lookup(admin_create_user_config.value, "sms_message", null) == null ? [] : [1]
        content {
          email_message = lookup(admin_create_user_config.value, "email_message")
          email_subject = lookup(admin_create_user_config.value, "email_subject")
          sms_message   = lookup(admin_create_user_config.value, "sms_message")
        }
      }
    }
  }

  lifecycle {
    # Hack to workaround issue with AWS changing approach and TF AWS Provider not having been updated yet.
    # https://github.com/terraform-providers/terraform-provider-aws/issues/8827#issuecomment-567041332
    ignore_changes = [
      "admin_create_user_config[0].unused_account_validity_days"
    ]
    # Enable prevent destroy
    # prevent_destroy = true
  }

  tags = merge(
    {
      Name = var.user_pool_name
      owner = var.owner
      namespace = var.namespace
      environment = var.environment
    },
    var.tags
  )
}

locals {

  # admin_create_user_config
  # If no admin_create_user_config list is provided, build a admin_create_user_config using the default values
  admin_create_user_config_default = {
    allow_admin_create_user_only = lookup(var.admin_create_user_config, "allow_admin_create_user_only", null) == null ? var.admin_create_user_config_allow_admin_create_user_only : lookup(var.admin_create_user_config, "allow_admin_create_user_only")
    unused_account_validity_days = lookup(var.admin_create_user_config, "unused_account_validity_days", null) == null ? var.admin_create_user_config_unused_account_validity_days : lookup(var.admin_create_user_config, "unused_account_validity_days")
    email_message                = lookup(var.admin_create_user_config, "email_message", null) == null ? (var.email_verification_message == "" || var.email_verification_message == null ? var.admin_create_user_config_email_message : var.email_verification_message) : lookup(var.admin_create_user_config, "email_message")
    email_subject                = lookup(var.admin_create_user_config, "email_subject", null) == null ? (var.email_verification_subject == "" || var.email_verification_subject == null ? var.admin_create_user_config_email_subject : var.email_verification_subject) : lookup(var.admin_create_user_config, "email_subject")
    sms_message                  = lookup(var.admin_create_user_config, "sms_message", null) == null ? var.admin_create_user_config_sms_message : lookup(var.admin_create_user_config, "sms_message")

  }

  admin_create_user_config = [local.admin_create_user_config_default]
}

resource "aws_cognito_user_pool_client" "client" {
  name = "client"
  user_pool_id = aws_cognito_user_pool.pool.id
  generate_secret     = true
  supported_identity_providers = ["COGNITO"]
  callback_urls = (var.callback_url != "") ? [var.callback_url] : var.callback_urls
  default_redirect_uri = var.default_redirect_uri
  logout_urls = var.logout_urls
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = ["email", "aws.cognito.signin.user.admin", "openid"]
  allowed_oauth_flows = ["code"]
}

resource "aws_cognito_user_pool_client" "additional_clients" {
  count           = length(var.additional_clients)
  name            = var.additional_clients[count.index].name
  user_pool_id    = aws_cognito_user_pool.pool.id
  generate_secret = true
  supported_identity_providers = ["COGNITO"]

  callback_urls        = var.additional_clients[count.index].callback_urls
  default_redirect_uri = var.additional_clients[count.index].default_redirect_uri
  logout_urls          = var.additional_clients[count.index].logout_urls
  explicit_auth_flows  = var.additional_clients[count.index].explicit_auth_flows

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
