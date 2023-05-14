variable "rds_name" {
  description = "The name of the RDS instance"
}

variable "subnet_ids" {
  description = "A list of IDs of the subnets where the RDS instance will be created"
}

variable "vpc_id" {
  description = "The ID of the VPC where the RDS instance will be created"
}

variable "engine" {
  description = "The database engine to use for the RDS instance"
}

variable "engine_version" {
  description = "The version of the database engine to use for the RDS instance"
}

variable "instance_class" {
  description = "The instance class for the RDS instance"
}

variable "username" {
  description = "The username for the master user of the RDS instance"
}

variable "password" {
  description = "The password for the master user of the RDS instance"
}

variable "vpc_security_group_ids" {
  description = "A list of IDs of the security groups to associate with the RDS instance"
}
