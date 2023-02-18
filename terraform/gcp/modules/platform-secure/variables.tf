#general
variable "project_id" {
  type        = string
  description = "name of the project in google cloud"
}

variable "domain" {
  type        = string
  description = "domain of the cluster"
}

variable "region" {
  type        = string
  description = "cluster's region"
}

variable "cluster_name" {
   type        = string
   description = "cluster's name"
}

variable "dns_project" {
  type        = string
  description = "cloudDNS project"
}

variable "environment" {
  type        = string
  description = "environment name"
}

#monitoring

# variable "enable_monitoring" {
#   type        = number
#   description = "deploy monitoring stack (grafana + prom)"
#   default     = 0
# }


#gh-runner
variable "enable_github_runner" {
  type        = number
  description = "if to enable github runner"
  default     = 0
}
#cert manager
variable "enable_cert_manager" {
  type        = number
  description = "deploy cert-manager with let's encrypt clusterissuers"
  default     = 0
}
variable "artifactory_sa_email" {
  type        = string
  description = "already made service account to pull from cloud artifactory"
  default     = null
}
variable "devops_email" {
  type        = string
  description = "org's devops team email"
}

#Pub/Sub
variable "pubsub_topics" {
  type        = list(any)
  description = "pubsub topics to create per name"
  default     = []
}

# DNS
variable "clouddns_sa_email" {
  type        = string
  description = "already made service account to sync records in google CloudDNS"
  default     = null
}

# scheduler
variable "scheduler_jobs" {
  type        = map(list(string))
  description = "scheduler jobs to create, schema: {'name': ['cron_pattern', 'time_zone']}"
  default     = {}
}

#certs manager
variable "google_secret_manager_keys" {
  type        = list(any)
  description = "all secret keys that present in secret manager for the application to fetch"
  default     = []
}

# service accounts
variable "old_service_accounts" {
  type        = list(any)
  description = "all service accounts that was already made for microservices"
  default     = []
}


# sql instance
variable "sql_disk_size" {
  type        = number
  description = "sql instance's disk size"
  default     = 100
}

variable "sql_high_available" {
  type        = bool
  default     = false
  description = "whether to create replicas for the sql instance"
}

variable "sql_region" {
  type        = string
  description = "sql instance's region"
  default     = "us-central1"
}

variable "sql_databases" {
  type        = list(any)
  description = "sql instance's databases"
  default     = []
}

variable "sql_tier" {
  type        = string
  description = "sql instance machine"
  default     = "db-custom-4-26624"
}
variable "sql_require_ssl" {
  type        = bool
  description = "whether the google sql instance requires ssl for connections"
  default     = false
}