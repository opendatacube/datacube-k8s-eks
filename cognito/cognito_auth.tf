# ======================================
# COGNITO

resource "aws_cognito_user_pool" "pool" {
  name                     = var.user_pool_name
  alias_attributes         = ["email"]
  auto_verified_attributes = var.auto_verify ? ["email"] : null

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
    minimum_length                   = 8
    require_uppercase                = true
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = false
    temporary_password_validity_days = 7
  }

  # admin_create_user_config
  dynamic "admin_create_user_config" {
    for_each = local.admin_create_user_config
    content {
      allow_admin_create_user_only = lookup(admin_create_user_config.value, "allow_admin_create_user_only")

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
    # Enable prevent destroy
    # prevent_destroy = true
  }

  tags = merge(
    {
      Name        = var.user_pool_name
      owner       = var.owner
      namespace   = var.namespace
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
    email_message                = lookup(var.admin_create_user_config, "email_message", null) == null ? (var.email_verification_message == "" || var.email_verification_message == null ? var.admin_create_user_config_email_message : var.email_verification_message) : lookup(var.admin_create_user_config, "email_message")
    email_subject                = lookup(var.admin_create_user_config, "email_subject", null) == null ? (var.email_verification_subject == "" || var.email_verification_subject == null ? var.admin_create_user_config_email_subject : var.email_verification_subject) : lookup(var.admin_create_user_config, "email_subject")
    sms_message                  = lookup(var.admin_create_user_config, "sms_message", null) == null ? var.admin_create_user_config_sms_message : lookup(var.admin_create_user_config, "sms_message")

  }

  admin_create_user_config = [local.admin_create_user_config_default]

  token_validity_units_default = {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}

resource "aws_cognito_user_pool_client" "clients" {
  for_each                     = var.app_clients
  name                         = each.key
  user_pool_id                 = aws_cognito_user_pool.pool.id
  generate_secret              = true
  supported_identity_providers = ["COGNITO"]

  callback_urls        = each.value.callback_urls
  default_redirect_uri = each.value.default_redirect_uri
  logout_urls          = each.value.logout_urls
  explicit_auth_flows  = each.value.explicit_auth_flows

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "aws.cognito.signin.user.admin", "openid"]
  allowed_oauth_flows                  = ["code"]

  dynamic "analytics_configuration" {
    for_each = var.enable_pinpoint ? [1] : []
    content {
      application_arn  = aws_pinpoint_app.pinpoint_app[each.key].arn
      user_data_shared = true
    }
  }

  token_validity_units {
    access_token  = lookup(each.value, "token_validity_units", null) == null ? local.token_validity_units_default.access_token : each.value.token_validity_units.access_token
    id_token      = lookup(each.value, "token_validity_units", null) == null ? local.token_validity_units_default.id_token : each.value.token_validity_units.id_token
    refresh_token = lookup(each.value, "token_validity_units", null) == null ? local.token_validity_units_default.refresh_token : each.value.token_validity_units.refresh_token
  }
  access_token_validity  = lookup(each.value, "access_token_validity", 60)
  id_token_validity      = lookup(each.value, "id_token_validity", 60)
  refresh_token_validity = lookup(each.value, "refresh_token_validity", 30)

}

resource "aws_cognito_user_pool_domain" "domain" {
  domain       = var.user_pool_domain
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_group" "group" {
  for_each     = var.user_groups
  user_pool_id = aws_cognito_user_pool.pool.id
  name         = each.key
  description  = each.value.description
  precedence   = each.value.precedence
}