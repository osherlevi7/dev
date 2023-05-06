variable "project_id" {}
variable "cluster_name" {}
variable "region" {}

module "dashboard" {

  source                      = "../../modules/k8s-dashboard"
  cluster_name                = var.cluster_name
  project_id                  = var.project_id
  region                      = var.region
  # dashboard settings
  kubernetes_resources_labels = {"k8s-app" = "kubernetes-dashboard"}
  kubernetes_deployment_image_tag = "v2.7.0"
  kubernetes_deployment_metrics_scraper_image_tag = "v1.0.8"
  domain              = "domain.com"
}

