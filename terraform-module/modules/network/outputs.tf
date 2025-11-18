output "network_id" {
  value = google_compute_network.vpc.id
}

output "network_name" {
  value = google_compute_network.vpc.name
}

output "app_subnet_id" {
  value = google_compute_subnetwork.app.id
}

output "nat_subnet_id" {
  value = google_compute_subnetwork.nat.id
}

output "proxy_subnet_id" {
  value = google_compute_subnetwork.proxy.id
}
