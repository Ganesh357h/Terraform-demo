# 1️⃣ Allow SSH from anywhere (you can restrict later)
resource "google_compute_firewall" "allow_ssh" {
  name      = "allow-ssh"
  network   = var.network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-allowed"]
}

# 2️⃣ Allow Google LB Health Check (8080)
resource "google_compute_firewall" "allow_health_check" {
  name      = "allow-health-check"
  network   = var.network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]

  target_tags  = ["health-check-allowed"]
  description  = "Allow Google LB health check traffic on port 8080"
}

# 3️⃣ Allow public/proxy traffic on port 8080
resource "google_compute_firewall" "allow_proxy" {
  name      = "allow-proxy"
  network   = var.network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["proxy-allowed"]
  description   = "Allow public access to port 8080"
}

# 4️⃣ Allow HTTP (80)
resource "google_compute_firewall" "allow_http" {
  name      = "allow-http"
  network   = var.network
  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
  description   = "Allow HTTP traffic on port 80"
}
