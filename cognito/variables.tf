variable "callback_url" {
  type = string
  description = "The callback url for your application"
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

variable "auto_verify" {
  description = "Set to true to allow the users account to be auto verified. False - admin will need to verify"
  type = bool
}

#--------------------------------------------------------------
# Tags
#--------------------------------------------------------------
variable "cluster_id" {
}

variable "environment" {
}

variable "namespace" {
}

variable "owner" {
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
  default     = "{username}, your verification code is `{####}`"
}


variable "admin_create_user_config_email_subject" {
  description = "The subject line for email messages"
  type        = string
  default     = "Your verification code"
}

variable "admin_create_user_config_sms_message" {
  description = "- The message template for SMS messages. Must contain `{username}` and `{####}` placeholders, for username and temporary password, respectively"
  type        = string
  default     = "Your username is {username} and temporary password is `{####}`"
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

