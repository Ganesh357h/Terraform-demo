Terraform AWS VPC Module
📌 Overview

This repository provisions an AWS Virtual Private Cloud (VPC) using Terraform with a reusable module-based architecture.

It creates:

A VPC

Public subnets across multiple Availability Zones

Private subnets across multiple Availability Zones

Internet Gateway

Route Tables for public and private subnets

NAT Gateway routing for private subnets

Outputs for VPC ID and subnet IDs

The architecture is modular, scalable, and follows Terraform best practices.

📁 Folder Structure
.
├── main.tf              # Root module calling the VPC module
├── variables.tf         # Root input variables
├── provider.tf          # AWS provider configuration
├── terraform.tfvars     # Environment-specific values
├── output.tf            # Outputs from the VPC module
└── modules/
    └── vpc/
        ├── main.tf      # VPC and networking resources
        ├── variables.tf
        └── outputs.tf

🌍 AWS Region

This setup uses the following AWS region:

us-east-1

⚙️ Provider Configuration
provider "aws" {
  region     = "us-east-1"
  access_key = "<YOUR_ACCESS_KEY>"
  secret_key = "<YOUR_SECRET_KEY>"
}


⚠️ Security Note
Do not hardcode credentials in production.
Use one of the following instead:

Environment variables

AWS CLI profiles

IAM roles (recommended)

🧩 Root Module (main.tf)

The root module consumes the reusable VPC module.

module "vpc" {
  source = "./modules/vpc"

  vpc_name           = var.vpc_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  public_subnets     = var.public_subnets
  public_subnet_azs  = var.public_subnet_azs

  private_subnets    = var.private_subnets
  private_subnet_azs = var.private_subnet_azs
}

📝 Input Variables (terraform.tfvars)
vpc_name = "prod-vpc"
vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "us-east-1a",
  "us-east-1b"
]

public_subnets = [
  "10.0.2.0/24",
  "10.0.4.0/24"
]

public_subnet_azs = [
  "us-east-1a",
  "us-east-1b"
]

private_subnets = [
  "10.0.0.0/25",
  "10.0.3.0/24"
]

private_subnet_azs = [
  "us-east-1b",
  "us-east-1c"
]

📤 Outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

Available Outputs

VPC ID

Public Subnet IDs

Private Subnet IDs

📦 VPC Module Details (modules/vpc)
1️⃣ VPC

Creates a VPC using the provided CIDR

DNS support enabled

Tagged with the VPC name

2️⃣ Internet Gateway

Attached to the VPC

Used by public subnets for internet access

3️⃣ Public Subnets

Created using count

Distributed across multiple Availability Zones

Associated with the public route table

map_public_ip_on_launch = false

Public access is controlled using ALB or NAT

4️⃣ Private Subnets

Created across multiple Availability Zones

No direct internet access

Routes traffic through NAT Gateway

5️⃣ Public Route Table

Route: 0.0.0.0/0 → Internet Gateway

Associated with all public subnets

6️⃣ NAT Gateway (Protected Resource)
lifecycle {
  prevent_destroy = true
}


Terraform is not allowed to delete the NAT Gateway

Prevents accidental deletion in production

Useful when NAT is shared or manually created

7️⃣ Private Route Table

Route: 0.0.0.0/0 → NAT Gateway

Used by all private subnets

Protected using lifecycle rules

🚀 How to Use
1️⃣ Initialize Terraform
terraform init

2️⃣ Validate Configuration
terraform validate

3️⃣ Review Execution Plan
terraform plan

4️⃣ Apply Infrastructure
terraform apply
