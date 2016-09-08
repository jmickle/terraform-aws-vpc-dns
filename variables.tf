variable "name" {}

variable "cidr" {}

variable "enable_dns_hostnames" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "public_subnet_cidr_a" {
  description = "CIDR of Region A Subnet"
}

variable "public_subnet_cidr_b" {
  description = "CIDR of region B subnet"
}

variable "public_subnet_cidr_c" {
  description = "CIDR of region C subnet"
}

variable "region" {
  description = "AWS Region"
}

variable "public_nat_gw_ipalloc_a" {}
variable "public_nat_gw_ipalloc_b" {}
variable "public_nat_gw_ipalloc_c" {}

variable "admin_subnet_cidr" {}

variable "internal_dns_zone" {}

variable "environment" {}