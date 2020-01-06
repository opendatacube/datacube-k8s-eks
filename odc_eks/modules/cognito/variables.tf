variable "cognito_auth_enabled" {
  default = false
}

variable "callback_url" {
  default     = "https:///jhub.example.com/oauth_callback"
  description = "The callback url for your application"
}

variable "user_pool_name" {
  description = "The cognito user pool name"
}

variable "user_pool_domain" {
  description = "The cognito user pool domain"
}

variable "cognito_user_groups" {
  default = []
  description = "List of user group objects manage by cognito user pool"
  type = list(object({
    name = string
    description = string
    precedence = number
  }))
}