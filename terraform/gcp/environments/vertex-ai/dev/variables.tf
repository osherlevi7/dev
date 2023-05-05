variable "maintainer_name" {
  type        = string
  description = "Insert your name: "
}

variable "machine_type" {
  type = string

}
variable "project_id" {
  type        = string
  description = "Project ID"

}



variable "region" {
  type        = string
  description = "Notebook's region"

}

variable "boot_disk_size_gb" {
  type        = number
  description = "Insert the boot disk size"

}

variable "boot_disk_type" {
  type        = string
  description = "Insert the boot disk type"

}

variable "data_disk_size_gb" {
  type        = number
  description = "Insert the data disk size"
  default     = 50
}

variable "data_disk_type" {
  type        = string
  description = "Insert the boot disk type"
  default     = "PD_SSD"
}

variable "gpu_driver" {
  type        = string
  description = "Rather to install the GPU driver or not"
}
variable "public_ip" {
  type        = string
  description = "Rather to create public IP or not"

}



variable "environment" {
  type        = string
  description = "Name of the environment"
}

variable "backend_bucket" {
  type = string
  description = "Name of the backend bucket"
}