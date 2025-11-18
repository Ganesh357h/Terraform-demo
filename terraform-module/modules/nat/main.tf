resource "google_compute_router" "router" {
  name    = var.router_name
  region  = var.region
  network = var.network_id
}

resource "google_compute_router_nat" "nat" {
  name                   = "nat-gateway"
  router                 = google_compute_router.router.name
  region                 = var.region
  nat_ip_allocate_option = "AUTO_ONLY"

  # NAT only the App subnet
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = var.app_subnet_id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
