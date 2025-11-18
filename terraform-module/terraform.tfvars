project_id = "terraformtraining-461819"

region = "us-east1"
zone   = "us-east1-b"

network_name       = "my-vpc"
app_subnet_cidr    = "10.10.10.0/24"
nat_subnet_cidr    = "10.10.20.0/24"
proxy_subnet_cidr  = "10.10.30.0/24"

machine_type = "e2-micro"
target_size  = 2
