variable "vpc_id" {
  description = "The ID of the VPC where the Elastic Load Balancer will be created"
}

variable "subnets" {
  description = "A list of IDs of the subnets where the Elastic Load Balancer will be created"
}

variable "elb_name" {
  description = "The name of the Elastic Load Balancer"
}

variable "elb_port" {
  description = "The port on which the Elastic Load Balancer will listen for incoming traffic"
}

variable "instance_port" {
  description = "The port on which the Elastic Load Balancer will forward traffic to the backend instances"
}
