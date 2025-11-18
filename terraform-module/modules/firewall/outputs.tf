output "ssh_rule" {
  value = google_compute_firewall.allow_ssh.name
}
