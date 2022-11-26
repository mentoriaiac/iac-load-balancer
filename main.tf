locals {
  image   = "nginx-v0-1-0"
  project = "mentoria-iac-staging"
}

provider "google" {
  project = local.project
  region  = "us-central1"
}

# Busca informações do groundwork.
data "google_compute_network" "groundwork" {
  name = "groundwork"
}

data "google_compute_subnetwork" "load_balancer" {
  name = "load-balancer"
}

# Firewall
resource "google_compute_firewall" "load_balancer_allow_public" {
  name        = "load-balancer-allow-public"
  description = "Permite acesso público às instâncias de load balancer."

  network       = data.google_compute_network.groundwork.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["load-balancer"]

  allow {
    protocol = "tcp"
    ports = [
      "22",   # SSH
      "80",   # HTTP
      "443",  # HTTPS
      "4646", # API Nomad
    ]
  }
}

# VMs
module "nginx" {
  source = "github.com/mentoriaiac/iac-modulo-compute-gcp?ref=v0.3.0"

  project = local.project

  instance_name  = "nginx-0"
  instance_image = local.image
  machine_type   = "e2-small"
  zone           = "us-central1-a"

  network    = data.google_compute_network.groundwork.name
  subnetwork = data.google_compute_subnetwork.load_balancer.name
  public_ip  = "ephemeral"

  labels = {
    projeto = "load_balancer"
  }

  tags = ["load-balancer"]
}
