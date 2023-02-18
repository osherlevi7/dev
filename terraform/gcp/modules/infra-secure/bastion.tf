
locals {
  bastion_name = format("%s-bastion", var.cluster_name)
  bastion_zone = format(var.region)
}

module "bastion" {
  source  = "terraform-google-modules/bastion-host/google"
  version = "~> 5.0"
  labels = {
    cluster = var.cluster_name
  }

  network        = module.vpc.network_self_link
  subnet         = module.vpc.subnets_self_links[0]
  project        = var.project_id
  host_project   = var.project_id
  name           = local.bastion_name
  zone           = "${var.region}-b"
  image_project  = "debian-cloud"
  fw_name_allow_ssh_from_iap = "allow-ssh-from-iap-to-tunnel-${var.cluster_name}"
  machine_type   = "f1-micro"
  startup_script = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y tinyproxy
  EOF
  members        = var.bastion_members
  shielded_vm    = "false"
  service_account_name = "bastion-${var.cluster_name}"
}
