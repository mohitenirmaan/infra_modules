variable "name" {
  description = "Name that will include to every resources"
  type = string
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "vpc_cidr" {
  description = "Vpc Network cidr"
  type = string
}
variable "enable_dns_support" {
  description = "Allow for DNS support "
  type = bool
}
variable "enable_dns_hostnames" {
  description = "Allow for DNS hostname"
  type = bool
}
variable "availability_zone" {
  description = "Define your AZ's in which you want your resources"
  type = list(string)
}
variable "public_subnet_cidrs" {
  description = "Provide CIDR range for public subnet"
  type = list(string)
}
variable "availability_zone_private" {
  description = "Define your AZ's in which you want your resources"
  type = list(string)
}
variable "private_subnet_cidrs" {
  description = "Provide CIDR range for public subnet"
  type = list(string)
}

