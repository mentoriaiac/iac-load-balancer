terraform {
  backend "gcs" {
    bucket = "mentoria-tfstate-staging"
    prefix = "iac-load-balancer"
  }
}
