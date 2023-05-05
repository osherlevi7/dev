# # https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    # bucket = "tf-state"
    # prefix = "terraform/${module.gke-cluster.project_id}/${module.gke-cluster.cluster_name}/infra/"
  }
}