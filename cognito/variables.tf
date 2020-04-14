variable "callback_url" {
  type = string
  description = "**Deprecated Var** - The callback url for your application"
  default = ""
}

variable "callback_urls" {
  type = list(string)
  description = "List of allowed callback URLs for the identity providers"
  default = []
}

variable "default_redirect_uri" {
  type = string
  description = "The default redirect URI. Must be in the list of callback URLs"
  default = ""
}

variable "logout_urls" {
  type = list(string)
  description = "List of allowed logout URLs for the identity providers"
  default = []
}

variable "user_pool_name" {
  type = string
  description = "The cognito user pool name"
}

variable "user_pool_domain" {
  type = string
  description = "The cognito user pool domain"
}

variable "user_groups" {
  default = []
  description = "List of user groups manage by cognito user pool"
  type = list(object({
    name = string
    description = string
    precedence = number
  }))
}

variable "app_clients" {
  default = []
  description = "List of user pool app clients to support multiple applications"
  type = list(object({
    name = string
    callback_urls = list(string)
    logout_urls = list(string)
    default_redirect_uri = string
    explicit_auth_flows = list(string)
  }))
}

variable "auto_verify" {
  description = "Set to true to allow the users account to be auto verified. False - admin will need to verify"
  type = bool
}

#--------------------------------------------------------------
# Tags
#--------------------------------------------------------------
variable "namespace" {
  type = string
  description = "The unique namespace for the environment, which could be your organization name or abbreviation"
}

variable "owner" {
  type = string
  description = "The owner of the environment"
}

variable "environment" {
  type = string
  description = "The name of the environment - e.g. dev, stage, prod"
}

# admin_create_user_config
variable "admin_create_user_config" {
  description = "The configuration for AdminCreateUser requests"
  type        = map
  default     = {}
}

variable "admin_create_user_config_allow_admin_create_user_only" {
  description = "Set to True if only the administrator is allowed to create user profiles. Set to False if users can sign themselves up via an app"
  type        = bool
  default     = false
}

variable "admin_create_user_config_unused_account_validity_days" {
  description = "The user account expiration limit, in days, after which the account is no longer usable"
  type        = number
  default     = 0
}

variable "admin_create_user_config_email_message" {
  description = "The message template for email messages. Must contain `{username}` and `{####}` placeholders, for username and temporary password, respectively"
  type        = string
  default     = null
}


variable "admin_create_user_config_email_subject" {
  description = "The subject line for email messages"
  type        = string
  default     = null
}

variable "admin_create_user_config_sms_message" {
  description = "The message template for SMS messages. Must contain `{username}` and `{####}` placeholders, for username and temporary password, respectively"
  type        = string
  default     = null
}

variable "email_verification_message" {
  description = "A string representing the email verification message"
  type        = string
  default     = null
}

variable "email_verification_subject" {
  description = "A string representing the email verification subject"
  type        = string
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Additional tags (e.g. `map('StackName','XYZ')`)"
  default     = {}
}
