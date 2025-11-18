resource "google_compute_instance_group_manager" "this" {
  name               = var.name
  base_instance_name = var.name
  zone               = var.zone

  version {
    instance_template = var.instance_template_link
  }

  target_size = var.target_size

  named_port {
    name = var.named_port_name
    port = var.named_port
  }
}
