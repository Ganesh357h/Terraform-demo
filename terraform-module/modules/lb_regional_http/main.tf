# 1️⃣ Regional HTTP Health Check
resource "google_compute_region_health_check" "this" {
  name   = "demo-health-check"
  region = var.region

  http_health_check {
    port_specification = "USE_FIXED_PORT"
    port               = var.health_check_port
    request_path       = var.health_check_path
    proxy_header       = "NONE"
  }

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

# 2️⃣ Backend Service (MIG backend)
resource "google_compute_region_backend_service" "this" {
  name                  = "flask-backend-service"
  region                = var.region
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_name             = var.backend_port_name
  timeout_sec           = 30

  backend {
    group            = var.backend_group
    balancing_mode   = "UTILIZATION"
    capacity_scaler  = 1.0
    max_utilization  = 0.8
  }

  health_checks = [
    google_compute_region_health_check.this.id
  ]
}

# 3️⃣ URL Map
resource "google_compute_region_url_map" "this" {
  name    = var.url_map_name
  region  = var.region

  default_service = google_compute_region_backend_service.this.id
}

# 4️⃣ Target HTTP Proxy
resource "google_compute_region_target_http_proxy" "this" {
  name    = var.target_proxy_name
  region  = var.region
  url_map = google_compute_region_url_map.this.id
}

# 5️⃣ Regional Static IP
resource "google_compute_address" "this" {
  name   = var.address_name
  region = var.region
}

# 6️⃣ Forwarding Rule
resource "google_compute_forwarding_rule" "this" {
  name                  = var.forwarding_rule_name
  region                = var.region
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_protocol           = "TCP"
  port_range            = "80"

  target     = google_compute_region_target_http_proxy.this.id
  network    = var.network_id
  ip_address = google_compute_address.this.address
}
