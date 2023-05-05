module "gke-cluster" {

  source                      = "../../../modules/infra"
  cluster_name                = "dev-gke"
  project_id                  = "development-gcp-project"
  region                      = "us-east1"
  services_machine_type       = "e2-standard-8"
  infrastructure_machine_type = "e2-standard-2"
  environment                 = "dev"
  dns_project                 = "dns-gcp-project" # also for general secrets
  devops_email                = "devops_team@domain.ai"
}

