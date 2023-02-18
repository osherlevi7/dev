data "google_compute_network" "vpc" {
  name = "${var.cluster_name}-vpc"
}

