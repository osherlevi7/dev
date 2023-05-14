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

variable "elb_name" {
  description = "The name of the Elastic Load Balancer"
  default     = "example-elb"
}

variable "elb_port" {
  description = "The port on which the Elastic Load Balancer will listen for incoming traffic"
  default     = 80
}

variable "instance_port" {
  description = "The port on which the Elastic Load Balancer will forward traffic to the backend instances"
  default     = 8080
}

variable "ami_id" {
  description = "The ID of the Amazon Machine Image (AMI) to use for the instances in the Auto Scaling Group"
  default     = "ami-0123456789abcdef"
}

variable "instance_type" {
  description = "The instance type for the instances in the Auto Scaling Group"
  default     = "t2.micro"
}

variable "asg_name" {
  description = "The name of the Auto Scaling Group"
  default     = "example-asg"
}

variable "asg_security_group_id" {
  description = "The ID of the security group to use for the instances in the Auto Scaling Group"
  default     = "sg-0123456789abcdef"
}

variable "min_size" {
  description = "The minimum number of instances in the Auto Scaling Group"
  default     = 2
}

variable "max_size" {
  description = "The maximum number of instances in the Auto Scaling Group"
  default     = 10
}

variable "desired_capacity" {
  description = "The desired number of instances in the Auto Scaling Group"
  default     = 2
}

variable "environment" {
  description = "The environment for the Auto Scaling Group"
  default     = "dev"
}

variable "rds_name" {
  description = "The name of the RDS instance"
  default     = "example-rds"
}

variable "engine" {
  description = "The database engine to use for the RDS instance"
  default     = "postgres"
}