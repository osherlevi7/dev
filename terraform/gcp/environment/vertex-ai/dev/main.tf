module "vertex-ai" {
  maintainer_name = var.maintainer_name
  source          = "../../../modules/vertex-ai"
  project_id      = var.project_id
  region          = var.region
  backend_bucket  = var.backend_bucket
  environment     = var.environment

  machine_type      = var.machine_type
  boot_disk_size_gb = var.boot_disk_size_gb
  boot_disk_type    = var.boot_disk_type
  data_disk_size_gb = var.data_disk_size_gb
  data_disk_type    = var.data_disk_type
  gpu_driver        = var.gpu_driver
  public_ip         = var.public_ip
}
