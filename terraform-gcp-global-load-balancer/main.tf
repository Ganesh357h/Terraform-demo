# Instance Template
#########################
resource "google_compute_instance_template" "tmpl" {
  name_prefix  = "global-lb-tmpl-"
  machine_type = "e2-micro"

  disk {
    boot         = true
    auto_delete  = true
    source_image = "projects/debian-cloud/global/images/family/debian-12"
  }

  tags = ["web"]

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    ZONE=$(curl -H "Metadata-Flavor: Google" \
      http://metadata.google.internal/computeMetadata/v1/instance/zone | awk -F/ '{print $4}')
    echo "<h1>Served from $ZONE</h1>" > /var/www/html/index.html
    systemctl enable nginx || true
    systemctl start nginx || true
  EOF
}

#########################
# Regional Managed Instance Groups
#########################

# Mumbai (asia-south1) - regional MIG
resource "google_compute_region_instance_group_manager" "mumbai_mig" {
  name               = "mig-mumbai"
  region             = "asia-south1"
  base_instance_name = "mum"

  version {
    instance_template = google_compute_instance_template.tmpl.self_link
  }

  target_size = 2

  named_port {
    name = "http"
    port = 80
  }
}

# Singapore (asia-southeast1) - regional MIG
resource "google_compute_region_instance_group_manager" "singapore_mig" {
  name               = "mig-sing"
  region             = "asia-southeast1"
  base_instance_name = "sing"

  version {
    instance_template = google_compute_instance_template.tmpl.self_link
  }

  target_size = 2

  named_port {
    name = "http"
    port = 80
  }
}

#########################
# Health Check
#########################
resource "google_compute_health_check" "hc" {
  name = "http-hc"

  http_health_check {
    request_path = "/"
    port         = 80
  }

  # Optional: set check interval, timeout, healthy/unhealthy thresholds
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
}

#########################
# Backend Service (Global)
#########################
resource "google_compute_backend_service" "backend" {
  name     = "global-backend"
  protocol = "HTTP"

  # attach health check
  health_checks = [google_compute_health_check.hc.self_link]

  # Backends: use instance_group attribute from region instance group managers
  backend {
    group = google_compute_region_instance_group_manager.mumbai_mig.instance_group
  }

  backend {
    group = google_compute_region_instance_group_manager.singapore_mig.instance_group
  }

  # Optional settings
  timeout_sec = 10
  port_name   = "http"
}

#########################
# URL map, HTTP proxy, global address & forwarding rule
#########################
resource "google_compute_url_map" "url_map" {
  name            = "global-url-map"
  default_service = google_compute_backend_service.backend.self_link
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "global-http-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

resource "google_compute_global_address" "global_ip" {
  name = "global-ip"
}

resource "google_compute_global_forwarding_rule" "http_rule" {
  name        = "http-forward"
  ip_address  = google_compute_global_address.global_ip.address
  port_range  = "80"
  target      = google_compute_target_http_proxy.http_proxy.self_link
}

#########################
# Firewall rules (CRITICAL)
#########################
# Allow GCP health check probes (required)
resource "google_compute_firewall" "allow_health_checks" {
  name    = "allow-health-checks"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  # Health check source ranges used by Google
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  target_tags = ["web"]
}

# Allow public HTTP traffic
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["web"]
}

#########################
# Output
#########################
output "global_load_balancer_ip" {
  description = "Global anycast IP for the HTTP load balancer"
  value       = google_compute_global_address.global_ip.address
}
