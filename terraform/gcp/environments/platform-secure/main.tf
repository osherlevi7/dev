variable project_id {}
variable cluster_name {}
variable environment {}
variable region {}

module "gke-platform" {

  source       = "../../modules/platform-secure"
  cluster_name = var.cluster_name
  project_id   = var.project_id
  environment  = var.environment
  region       = var.region

  # service accounts secrets settings
  clouddns_sa_email    = "compute@developer.gserviceaccount.com"

  #  pubsub & scheduler settings
  pubsub_topics = []
  scheduler_jobs = {
    "appointments" : ["GET", "* * * * *", "Africa/Abidjan"],
    "appointment-reminder" : ["GET", "0 * * * *", "US/Central"],
    "transactions-job" : ["POST", "0 0 * * *", "Africa/Abidjan"],
    "function" : ["GET", "* * * * *", "Africa/Abidjan"],
    "schedule-job" : ["POST", "* * * * *", "US/Central"],
    "shifts" : ["GET", "0 13 * * *", "America/New_York"],
    "updated" : ["GET", "0 1 * * *", "Etc/GMT"],
  }

  # service accounts secrets settings
  artifactory_sa_email = "artifacts-sa-rw@artifactory.iam.gserviceaccount.com"
  # clouddns_sa_email    = "compute@developer.gserviceaccount.com"
  devops_email         = "devops_team@domain.ai"

  # dns settings  
  enable_cert_manager = 0         # using google managed certs, will be deployed if enable_github_runner is deployed, but wont deploy issuers
  dns_project         = "dns-gcp-project" # also for general secrets
  domain              = "domain.ai"
  # sub_domain          = "dev"

  # sql instance settings
  sql_region         = "us-east1"
  sql_disk_size      = 100
  sql_require_ssl    = false
  sql_tier           = "db-custom-4-26624"
  sql_high_available = false
  sql_databases      = ["a", "b", "c", "d"]

  # cluster_cidr = "10.48.0.0/14"
}

