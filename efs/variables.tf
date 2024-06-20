variable "private_subnet_ids" {
 type = list(string) 
}
variable "security_group_ids" {
 type = list(string) 
}

variable "name" {
  description = "Name that will include to every resources"
  type = string
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "creation_token" {
  type = string
}
variable "encrypted" {
  type = bool
}
variable "throughput_mode" {
  type = string
}
variable "transition_to_ia" {
  type = string
}
