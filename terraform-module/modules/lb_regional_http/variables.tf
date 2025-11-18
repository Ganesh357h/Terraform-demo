variable "region" {
  type = string
}

variable "network_id" {
  type = string
}

variable "backend_group" {
  type = string
}

variable "backend_port_name" {
  type = string
}

variable "health_check_path" {
  type = string
}

variable "health_check_port" {
  type = number
}

variable "url_map_name" {
  type = string
}

variable "target_proxy_name" {
  type = string
}

variable "address_name" {
  type = string
}

variable "forwarding_rule_name" {
  type = string
}
