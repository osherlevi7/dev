variable "project_id" {}
variable "sub_domain" {}
variable "region" {}

module "monitor-serverless" {

  source     = "../../modules/monitoring-grafana/"
  project_id = var.project_id
  region     = var.region
  sub_domain = var.sub_domain
  # dns_project                 = "dns-project" # also for general secrets
}

