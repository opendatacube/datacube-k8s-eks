# ======================================
# COGNITO

locals {
  alias_attributes = var.alias_attributes == null && var.username_attributes == null ? ["email"] : null

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
  allowed_oauth_scopes_default = ["email", "aws.cognito.signin.user.admin", "openid"]
  allowed_oauth_flows_default  = ["code"]
}

resource "aws_cognito_user_pool" "pool" {
  name                     = var.user_pool_name
  alias_attributes         = var.alias_attributes != null ? var.alias_attributes : local.alias_attributes
  username_attributes      = var.username_attributes
  auto_verified_attributes = var.auto_verify ? var.auto_verified_attributes : null

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

  dynamic "username_configuration" {
    for_each = var.enable_username_case_sensitivity != null ? [true] : []
    content {
      case_sensitive = var.enable_username_case_sensitivity
    }
  }

  # Limitations:
  # - standard attributes can only be selected during the pool creation and cannot be changed
  # - standard attributes cannot be switched between required and not required after a user pool has been created
  # - custom attributes can be defined as a string or a number only
  # - custom attributes can't be set to required
  # - custom attributes can't be removed or changed once added to the user pool
  dynamic "schema" {
    for_each = var.schema_additional_attributes
    iterator = attribute
    content {
      name                     = attribute.value.attribute_name
      attribute_data_type      = attribute.value.attribute_data_type
      developer_only_attribute = try(attribute.value.developer_only_attribute, false)
      mutable                  = try(attribute.value.mutable, true)
      required                 = try(attribute.value.required, false)

      dynamic "number_attribute_constraints" {
        for_each = attribute.value.attribute_data_type == "Number" ? [true] : []

        content {
          min_value = lookup(attribute.value, "min_value", null)
          max_value = lookup(attribute.value, "max_value", null)
        }
      }

      dynamic "string_attribute_constraints" {
        for_each = attribute.value.attribute_data_type == "String" ? [true] : []

        content {
          min_length = lookup(attribute.value, "min_length", 0)
          max_length = lookup(attribute.value, "max_length", 2048)
        }
      }
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
    ignore_changes = [
      lambda_config  # Create these linkages with a null_resource to avoid circular dependencies
    ]
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
  allowed_oauth_scopes                 = lookup(each.value, "allowed_oauth_scopes", local.allowed_oauth_scopes_default)
  allowed_oauth_flows                  = lookup(each.value, "allowed_oauth_flows", local.allowed_oauth_flows_default)

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
