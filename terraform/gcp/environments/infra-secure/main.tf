variable project_id {}
variable cluster_name {}
variable region {}

module "gke-cluster" {

  source                      = "../../modules/infra-secure"
  cluster_name                = var.cluster_name
  project_id                  = var.project_id
  region                      = var.region
  services_machine_type       = "e2-standard-8"
  infrastructure_machine_type = "e2-standard-2"
  dns_project                 = "dns-gcp-project" # also for general secrets
  devops_email                = "devops_team@domain.ai"
}

