resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  description             = "Custom VPC for app and nat subnets"
}

resource "google_compute_subnetwork" "app" {
  name          = "app-subnet"
  ip_cidr_range = var.app_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "nat" {
  name          = "nat-subnet"
  ip_cidr_range = var.nat_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "proxy" {
  name          = "proxy-subnet"
  ip_cidr_range = var.proxy_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id

  # Required for External HTTP(S) LB
  purpose = "REGIONAL_MANAGED_PROXY"
  role    = "ACTIVE"

  description = "Proxy-only subnet for regional external HTTP(S) load balancer"
}
