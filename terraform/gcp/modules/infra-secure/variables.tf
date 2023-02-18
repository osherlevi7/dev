# GKE
variable "project_id" {
  type        = string
  description = "name of the project in google cloud"
}
variable "cluster_name" {
  type        = string
  description = "cluster's name"
}
variable "region" {
  type        = string
  description = "cluster's region"
}
variable "infrastructure_machine_type" {
  type        = string
  description = "cluster's infrastructure node pool machine"
  default     = "e2-small"
}
variable "services_machine_type" {
  type        = string
  description = "cluster's services node pool machine"
  default     = "e2-small"
}
#variable "bucket" {
#  type        = string
#  description = "the name of the bucket to save tf files"
#}

# # cert-gh_runner
variable "enable_github_runner" {
  type        = number
  description = "if to enable github runner"
  default     = 0
}
variable "devops_email" {
  type        = string
  description = "org's devops team email"
}
variable "dns_project" {
  type        = string
  description = "cloudDNS project"
}

#bastion sercured 
variable "bastion_members" {
  type        = list(string)
  description = "List of users, groups, SAs who need access to the bastion host"
  default     = []
}
