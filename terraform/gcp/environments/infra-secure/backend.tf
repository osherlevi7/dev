# # https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
#     bucket = "${terraform.bucket}"
#     prefix = "terraform/${terraform.project_id}/${terraform.cluster_name}/infra/"
      
  }
} 