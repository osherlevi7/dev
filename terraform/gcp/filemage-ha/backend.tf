# # https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket = "filemage-ha-state-tf-development"
    prefix = "terraform/state"
  }
}
