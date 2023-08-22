# save state on S3
# # https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "s3" {
    bucket = "phishing-tf-state-dev"
    prefix = "terraform/state"
    # key    =  ""
  }
}
