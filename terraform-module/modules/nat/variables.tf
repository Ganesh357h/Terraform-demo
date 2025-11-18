variable "region" {
  type = string
}

variable "network_id" {
  type = string
}

variable "router_name" {
  type    = string
  default = "router"
}

variable "app_subnet_id" {
  type = string
}
