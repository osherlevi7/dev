
locals {
  bastion_name = format("%s-bastion", var.cluster_name)
  bastion_zone = format(var.region)
}

# resource "template_file" "startup_script" {
#   template = <<-EOF
#   sudo apt-get update -y
#   sudo apt-get install -y tinyproxy
#   EOF
# }

module "bastion" {
  source  = "terraform-google-modules/bastion-host/google"
  version = "~> 5.0"

  network        = module.vpc.network_self_link
  subnet         = module.vpc.subnets_self_links[0]
  project        = var.project_id
  host_project   = var.project_id
  name           = local.bastion_name
  zone           = "${var.region}-b"
  image_project  = "debian-cloud"
  machine_type   = "g1-small"
  startup_script = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y tinyproxy
  EOF
  members        = var.bastion_members
  shielded_vm    = "false"
}