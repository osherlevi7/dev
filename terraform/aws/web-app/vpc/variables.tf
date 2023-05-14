variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks for the public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks for the private subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones to use for the VPC"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT gateway for the private subnets"
  default     = true
}

variable "create_database_subnet_group" {
  description = "Whether to create a database subnet group"
  default     = true
}

variable "database_subnet_cidr_blocks" {
  description = "List of CIDR blocks for the database subnets"
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "tags" {
  description = "Map of tags to apply to the resources"
  default     = {
    Environment = "dev"
  }
}
