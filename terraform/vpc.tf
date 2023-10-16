resource "aws_vpc" "vpc" {
  cidr_block                       = var.cidr
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "${var.project_name} VPC"
  }
}

