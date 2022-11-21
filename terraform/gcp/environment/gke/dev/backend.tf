# save state on gcs
# # https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket = "meyBucket-tf-state-dev"
    prefix = "terraform/state"
  }
}
