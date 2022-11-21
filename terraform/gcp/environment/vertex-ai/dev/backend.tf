# # https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket = "myBucket-tf-state-dev"
    prefix = "terraform/state"
  }
}
