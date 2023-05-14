variable "asg_name" {
  description = "The name of the Auto Scaling Group"
}

variable "ami_id" {
  description = "The ID of the Amazon Machine Image (AMI) to use for the instances in the Auto Scaling Group"
}

variable "instance_type" {
  description = "The instance type for the instances in the Auto Scaling Group"
}

variable "asg_security_group_id" {
  description = "The ID of the security group to use for the instances in the Auto Scaling Group"
}

variable "min_size" {
  description = "The minimum number of instances in the Auto Scaling Group"
}

variable "max_size" {
  description = "The maximum number of instances in the Auto Scaling Group"
}

variable "desired_capacity" {
  description = "The desired number of instances in the Auto Scaling Group"
}

variable "environment" {
  description = "The environment for the Auto Scaling Group"
}
