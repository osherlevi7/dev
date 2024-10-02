variable "pg_password" {
  type = string
  description = "PostgreSQL database password."
}

variable "region" {
  type = string
  default = "us-east1"
  
}

variable "zone" {
  type = string
  default = "us-east1-c"
}

variable "project" {
  type = string
  default = "develop"

}
