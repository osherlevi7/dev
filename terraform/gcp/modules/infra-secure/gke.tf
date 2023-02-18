data "external" "myip" {
  program   = [
    "/bin/bash", "${path.module}/extract_ip.sh"
  ]
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id                 = var.project_id 
  name                       = var.cluster_name
  remove_default_node_pool   = true
  region                     = var.region
  regional                   = var.cluster_name == "production" ? true : false
  zones                      = var.cluster_name == "production" ? ["${var.region}-c", "${var.region}-b", "${var.region}-d"] : ["${var.region}-c"]
  network                    = module.vpc.network_name
  subnetwork                 = "private-subnet-${var.cluster_name}"
  ip_range_pods              = "k8s-pod-range"
  ip_range_services          = "k8s-service-range"
  identity_namespace         = "${var.project_id}.svc.id.goog"
  kubernetes_version         = "1.22"
  http_load_balancing        = true
  network_policy             = false
  horizontal_pod_autoscaling = true
  release_channel            = "REGULAR"
  filestore_csi_driver       = false
  datapath_provider          = "ADVANCED_DATAPATH"
  enable_private_endpoint    = false
  enable_private_nodes       = true
  gke_backup_agent_config    = true
  logging_enabled_components = ["SYSTEM_COMPONENTS","WORKLOADS","APISERVER","SCHEDULER","CONTROLLER_MANAGER"]
  monitoring_enabled_components = ["SYSTEM_COMPONENTS","APISERVER","SCHEDULER","CONTROLLER_MANAGER"]
  master_ipv4_cidr_block  = "10.30.0.0/28"
  create_service_account  = true
  master_authorized_networks = [{
    cidr_block = "10.0.0.0/18"
    display_name = "VPC"
  }, { 
    cidr_block = format("%s/%s",data.external.myip.result.my_ip,32)
    display_name = "myip"
  }]
  cluster_resource_labels    = {
    cluster = var.cluster_name
  }
  
  node_pools = [
    {
      name               = "infrastructure"
      autoscaling        = true
      machine_type       = var.infrastructure_machine_type
      min_count          = 1
      max_count          = 10
      local_ssd_count    = 0
      spot               = false
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      enable_gcfs        = false
      enable_gvnic       = false
      auto_repair        = true
      auto_upgrade       = true
      #service_account    = format("%s@%s.iam.gserviceaccount.com", var.cluster_name, var.project_id)
      #service_account    = format("%s-%s@%s.iam.gserviceaccount.com",var.project_id, var.cluster_name)
      preemptible        = var.cluster_name == "production" ? false : true
      initial_node_count = 1
    },
    {
      name               = "services"
      autoscaling        = true
      machine_type       = var.services_machine_type
      min_count          = 0
      max_count          = 10
      local_ssd_count    = 0
      spot               = false
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      enable_gcfs        = false
      enable_gvnic       = false
      auto_repair        = true
      auto_upgrade       = true

      service_account    = format("%s-%s@%s.iam.gserviceaccount.com",var.project_id, var.cluster_name, var.project_id)
      preemptible        = var.cluster_name == "production" ? false : true
      initial_node_count = 0
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/service.management.readonly"
    ]
    services = [
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/logging.admin"
    ]
    infrastructure = []
  }

  node_pools_labels = {
    all = {
      cluster = var.cluster_name
    }

    infrastructure = {
      role = "master"
      team = "devops"
    }

    services = {
      role = "worker"
      team = "engineers"
    }
  }

  node_pools_metadata = {
    all            = {}
    services       = {}
    infrastructure = {}
  }

  node_pools_taints = {
    all            = []
    services       = []
    infrastructure = []
  }

  node_pools_tags = {
    all = []

    infrastructure = [
      "infrastructure-services",
    ]
    services = [
      "app-services",
    ]
  }

  depends_on = [
      module.vpc,
      data.external.myip,
#     helm_release.ingress-controller
  #   google_service_account.cluster-sa,
  #   google_project_service.project_services
  ]
}
