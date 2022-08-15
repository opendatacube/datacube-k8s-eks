variable "app_clients" {
  description = "Map of Cognito user pool app clients"
  type        = map(any)
}

variable "user_pool_name" {
  type        = string
  description = "Cognito user pool name"
}

variable "user_pool_domain" {
  type        = string
  description = "Cognito user pool domain"
}

variable "user_groups" {
  default     = {}
  description = "Map of Cognito user groups"
  type        = map(any)
}

variable "enable_pinpoint" {
  description = "Set to true to enable PinPoint based analytics module to be provisioned"
  type        = bool
  default     = false
}

variable "auto_verify" {
  description = "Set to true to allow the users account to be auto verified. False - admin will need to verify"
  type        = bool
}

variable "auto_verified_attributes" {
  description = "If auto_verify is true, which fields to auto verify. Valid values are: email, phone_number"
  type        = set(string)
  default     = [ "email" ]
}

variable "alias_attributes" {
  type        = set(string)
  description = "(Optional) Attributes supported as an alias for this user pool. Possible values: 'phone_number', 'email', or 'preferred_username'. Conflicts with username_attributes."
  default     = null
}

variable "username_attributes" {
  type        = set(string)
  description = "(Optional) Specifies whether email addresses or phone numbers can be specified as usernames when a user signs up. Conflicts with alias_attributes."
  default     = null
}

variable "enable_username_case_sensitivity" {
  type        = bool
  description = "(Optional) Specifies whether username case sensitivity will be applied for all users in the user pool through Cognito APIs."
  default     = null
}

#--------------------------------------------------------------
# Tags
#--------------------------------------------------------------
variable "namespace" {
  type        = string
  description = "The unique namespace for the environment, which could be your organization name or abbreviation"
}

variable "owner" {
  type        = string
  description = "The owner of the environment"
}

variable "environment" {
  type        = string
  description = "The name of the environment - e.g. dev, stage, prod"
}

# admin_create_user_config
variable "admin_create_user_config" {
  description = "The configuration for AdminCreateUser requests"
  type        = map(any)
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

variable "schema_additional_attributes" {
  description = "(Optional) A list of schema attributes of a user pool. You can add a maximum of 25 custom attributes."
  type        = any
  default     = []
  #
  # Example:
  #
  # schema_additional_attributes = [
  #   {
  #     attribute_name           = "alternative_name"
  #     attribute_data_type      = "String"
  #     developer_only_attribute = false,
  #     mutable                  = true,
  #     required                 = false,
  #     min_length               = 0,
  #     max_length               = 2048
  #   },
  # ]
}
