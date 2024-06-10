variable "name" {
  description = "Name that will include to every resources"
  type = string
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}
variable "vpc_id" {
  type = string
}
variable "private_subnet_ids" {
 type = list(string) 
}
variable "rds_sg_name" {
  type = string
}
variable "egress-cidr_blocks" {
  type = list(string)
}
#variable "db_subnet_group_name" {
#  type = string
#}

variable "db_instance_config" {
  description = "Configuration map for the RDS instance."
  type        = map(any)
}
