############################################
# 1. AUTOMATIC SSH KEY GENERATION
############################################
resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

############################################
# 2. CUSTOM VPC
############################################
resource "google_compute_network" "vpc" {
  name                    = "custom-vpc"
  auto_create_subnetworks = false
}

############################################
# 3. PUBLIC SUBNET
############################################
resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc.id
}

############################################
# 4. PRIVATE SUBNET
############################################
resource "google_compute_subnetwork" "private_subnet" {
  name                     = "private-subnet"
  ip_cidr_range            = "10.0.2.0/24"
  region                   = "us-central1"
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}

############################################
# 5. CLOUD ROUTER + NAT
############################################
resource "google_compute_router" "router" {
  name    = "nat-router"
  region  = "us-central1"
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "cloud_nat" {
  name                               = "cloud-nat"
  router                             = google_compute_router.router.name
  region                             = "us-central1"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

############################################
# 6. FIREWALL RULES
############################################

# Allow SSH to Bastion
resource "google_compute_firewall" "allow_ssh_to_bastion" {
  name      = "allow-ssh-bastion"
  network   = google_compute_network.vpc.id
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion"]
}

# Allow Bastion -> Private internal
resource "google_compute_firewall" "allow_bastion_to_private" {
  name      = "allow-bastion-private"
  network   = google_compute_network.vpc.id
  direction = "INGRESS"

  allow { protocol = "all" }

  source_ranges = ["10.0.1.0/24"]
  target_tags   = ["private"]
}

# Allow outbound
resource "google_compute_firewall" "allow_egress" {
  name      = "allow-egress"
  network   = google_compute_network.vpc.id
  direction = "EGRESS"

  allow { protocol = "all" }

  destination_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "bastion" {
  name         = "bastion-host"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  tags = ["bastion"]

  metadata = {
    ssh-keys = "ganeshbabukesavan:${tls_private_key.bastion_key.public_key_openssh}"
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    mkdir -p /home/ganeshbabukesavan/.ssh
    echo "${tls_private_key.bastion_key.private_key_pem}" > /home/ganeshbabukesavan/.ssh/id_rsa
    chmod 600 /home/ganeshbabukesavan/.ssh/id_rsa
    chown -R ganeshbabukesavan:ganeshbabukesavan /home/ganeshbabukesavan/.ssh
  EOT

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public_subnet.id
    access_config {}
  }
}


############################################
# 8. PRIVATE VM (public key only)
############################################
resource "google_compute_instance" "private_vm" {
  name         = "private-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  tags = ["private"]

metadata = {
  ssh-keys               = "ganeshbabukesavan:${tls_private_key.bastion_key.public_key_openssh}"
  block-project-ssh-keys = "true"
}


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet.id
  }
}

############################################
# 9. OUTPUT
############################################
output "bastion_public_ip" {
  value = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}
output "bastion_private_key" {
  value     = tls_private_key.bastion_key.private_key_pem
  sensitive = true
}
