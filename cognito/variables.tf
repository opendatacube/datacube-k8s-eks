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