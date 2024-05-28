variable "vpc_id" {
  type = string
}
variable "name" {
  description = "Name that will include to every resources"
  type = string
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}
variable "peer_owner_id" {
  description = "Account ID of Accepter"
  type = string
}
variable "peer_vpc_id" {
  description = "VPC Id of Accepter"
  type = string
}
