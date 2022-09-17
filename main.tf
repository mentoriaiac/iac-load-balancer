provider "google" {
  project = "mentoriaiac-20220916"
  region  = "us-central1"
}

locals {
  subnets = [data.google_compute_subnetwork.load-balance, data.google_compute_subnetwork.nomad]
}

data "google_compute_network" "vpc-network" {
  name = "vpc-network"
}

data "google_compute_subnetwork" "load-balance" {
  name = "load-balance"
}

data "google_compute_subnetwork" "nomad" {
  name = "nomad"
}

resource "google_compute_firewall" "load-balance" {
  name          = "load-balance"
  network       = data.google_compute_network.vpc-network.name
  source_ranges = ["0.0.0.0/0"]
  // destination_ranges = [data.google_compute_subnetwork.load-balance.ip_cidr_range]
  target_tags = ["load-balance"]
  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }

}

module "compute_gcp" {
  source         = "github.com/mentoriaiac/iac-modulo-compute-gcp"
  project        = "mentoriaiac-20220916"
  instance_name  = "nginx-0"
  instance_image = "nginx-20220917004516"
  machine_type   = "e2-small"
  zone           = "us-central1-a"
  network        = data.google_compute_network.vpc-network.name
  subnetwork     = local.subnets[0].name


  labels = {
    value = "key"
  }

  tags = ["load-balance"]

}

module "nomad" {
  source         = "github.com/mentoriaiac/iac-modulo-compute-gcp"
  project        = "mentoriaiac-20220916"
  instance_name  = "nginx-1"
  instance_image = "nginx-20220917004516"
  machine_type   = "e2-small"
  zone           = "us-central1-a"
  network        = data.google_compute_network.vpc-network.name
  subnetwork     = local.subnets[1].name
  public_ip      = "ephemeral"
  labels = {
    value = "key"
  }


  tags = []

}
