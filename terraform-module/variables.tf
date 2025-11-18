variable "credentials_file" {
  description = "Path to the GCP credentials JSON file"
  type        = string
  default     = "C:/Users/GaneshbabuKesavan/Downloads/Terraform/terraform-module/key.json"
  
}
variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east1"
}

variable "zone" {
  type    = string
  default = "us-east1-b"
}

variable "network_name" {
  type    = string
  default = "my-vpc"
}

variable "app_subnet_cidr" {
  type    = string
  default = "10.10.10.0/24"
}

variable "nat_subnet_cidr" {
  type    = string
  default = "10.10.20.0/24"
}

variable "proxy_subnet_cidr" {
  type    = string
  default = "10.10.30.0/24"
}

variable "machine_type" {
  type    = string
  default = "e2-micro"
}

variable "target_size" {
  type    = number
  default = 2
}
