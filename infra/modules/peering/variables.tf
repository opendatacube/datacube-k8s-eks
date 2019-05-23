variable "enable" {
  default = false
}

variable "vpc_id" {
  type = "string"
}

### Peer
variable "peer_vpc_id" {
  type = "string"
}

variable "peer_access_key" {
  type = "string"
}

variable "peer_secret_key" {
  type = "string"
}

variable "peer_region" {
  type = "string"
  default = "ap-southeast-2"
}

variable "peer_security_group_name_filter" {
  type = "string"
}

### Owner

variable "owner_vpc_cidr" {
  type = "string"
}

variable "owner_subnets_to_route" {
  type = "list"
}

variable "owner_security_group_name_filter" {
  type = "string"
}


