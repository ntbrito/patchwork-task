variable "aws_region" {
  description = "The AWS region we are setting this up in"
  default = "eu-west-2"
}

variable "avail_zones" {
  description = "The AWS AZs"
  type = list
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "project_name" {
  description = "The name of the project"
  default = "patchwork"
}

variable "cidr" {
  description = "The subnet for the entire vpc"
  default = "10.1.100.0/24"
}
