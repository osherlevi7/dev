#set provider for this project
provider "aws" {
  region = var.region
}
# Module VPC
module "vpc" {
  source = "./vpc"
  vpc_cidr_block = var.vpc_cidr_block
  public_subnets_cidr_blocks = var.public_subnets_cidr_blocks
  private_subnets_cidr_blocks = var.private_subnets_cidr_blocks
  availability_zones = var.availability_zones
}
# Module Elastic Load Balancer
module "elb" {
  source = "./elb"
  elb_name = var.elb_name
  elb_port = var.elb_port
  instance_port = var.instance_port
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
}
# Module Amazon Security Group
module "asg" {
  source = "./asg"
  asg_name = var.asg_name
  ami_id = var.ami_id
  instance_type = var.instance_type
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.desired_capacity
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.private_subnets
  elb_name = module.elb.elb_name
}
# Module Releation Database service
module "rds" {
  source = "./rds"
  rds_name = var.rds_name
  engine = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  username = var.username
  password = var.password
  vpc_security_group_ids = [module.vpc.vpc_default_security_group_id]
}
