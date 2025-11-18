# 1️⃣ Network module
module "network" {
  source            = "./modules/network"

  network_name      = var.network_name
  region            = var.region
  app_subnet_cidr   = var.app_subnet_cidr
  nat_subnet_cidr   = var.nat_subnet_cidr
  proxy_subnet_cidr = var.proxy_subnet_cidr
}

# 2️⃣ NAT module
module "nat" {
  source        = "./modules/nat"

  region        = var.region
  network_id    = module.network.network_id
  router_name   = "router"
  app_subnet_id = module.network.app_subnet_id
}

# 3️⃣ Firewall module
module "firewall" {
  source  = "./modules/firewall"
  network = module.network.network_name
}

# 4️⃣ Instance Template
module "compute_template" {
  source = "./modules/compute_template"

  name_prefix   = "flask-template-"
  machine_type  = var.machine_type
  network_id    = module.network.network_id
  app_subnet_id = module.network.app_subnet_id
}

# 5️⃣ MIG
module "mig" {
  source = "./modules/mig"

  name                   = "flask-app"
  zone                   = var.zone
  instance_template_link = module.compute_template.instance_template_self_link
  target_size            = var.target_size
  named_port_name        = "http"
  named_port             = 8080
}

# 6️⃣ Load Balancer
module "lb" {
  source = "./modules/lb_regional_http"

  region                 = var.region
  network_id             = module.network.network_id
  backend_group          = module.mig.instance_group
  backend_port_name      = "http"
  health_check_path      = "/health"
  health_check_port      = 8080
  url_map_name           = "flask-url-map"
  target_proxy_name      = "flask-http-proxy"
  address_name           = "flask-lb-ip"
  forwarding_rule_name   = "flask-forwarding-rule"
}
