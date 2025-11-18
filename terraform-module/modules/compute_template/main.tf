resource "google_compute_instance_template" "this" {
  name_prefix  = var.name_prefix
  machine_type = var.machine_type

  # Spot instance config
  scheduling {
    preemptible       = true
    automatic_restart = false
  }

  lifecycle {
    create_before_destroy = true
  }

  # Tags needed by firewall rules
  tags = [
    "http-server",
    "ssh-allowed",
    "health-check-allowed",
    "proxy-allowed"
  ]

  metadata = {
    enable-oslogin = "TRUE"

    startup-script = <<-EOF
      #!/bin/bash
      set -eux

      apt-get update -y
      apt-get install -y python3-pip python3-venv

      useradd -m -s /bin/bash appuser || true
      cd /home/appuser

      python3 -m venv venv
      /home/appuser/venv/bin/pip install --upgrade pip flask gunicorn

      # ✅ Flask app
      cat <<'PY' >/home/appuser/app.py
from flask import Flask
app = Flask(__name__)

@app.route("/")
def index():
    return "Hello from Flask on GCP!", 200

@app.route("/health")
def health():
    return "ok", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
PY

      # ✅ Systemd service
      cat <<'UNIT' >/etc/systemd/system/flask.service
[Unit]
Description=Flask App via Gunicorn
After=network.target

[Service]
User=appuser
WorkingDirectory=/home/appuser
ExecStart=/home/appuser/venv/bin/gunicorn -w 2 -b 0.0.0.0:8080 app:app
Restart=always

[Install]
WantedBy=multi-user.target
UNIT

      systemctl daemon-reload
      systemctl enable flask
      systemctl start flask
    EOF
  }

  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = var.network_id
    subnetwork = var.app_subnet_id
  }
}
