# https://registry.terraform.io/providers/hashicorp/google/latest/docs
provider "google" {
  project = var.project_id
  region  = var.region
}
provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

#data "google_container_cluster" "my_cluster" {
#  name = var.cluster_name
#  location = "${var.region}-c"
# depends_on = [
#   module.gke
# ]
#}

#When the GKE is secured with no publicIP the connection should be via tunnel command to the bastion-vm 
# Add /etc/hosts > 127.0.0.1 kubernetes
# Edit ~/.kube/config > - cluster: - name: - servcer: kubernetes 
provider "kubernetes" {
  #host  = "https://${data.google_container_cluster.my_cluster.endpoint}"
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  #cluster_ca_certificate = base64decode(
  #  data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
  #)
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# VERSIONS

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.22.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}
