variable "vpc_id" {
  type = string
}
variable "public_subnet_ids" {
 type = list(string) 
}
variable "private_subnet_ids" {
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
variable "security_groups" {
  description = "List of security group configurations"
  type = list(object({
    name           = string
    description    = string
    ingress_rules  = list(object({
      description = string
      port        = number
      protocol    = string
      cidr_block  = list(string)
    }))
  }))
}
variable "egress-cidr_blocks" {
  type = list(string)
}
variable "template_name" {
  type = list(string)
}
variable "template_description" {
  type = list(string)
}
variable "volume_size" {
  type = list(string)
}
variable "image_ids" {
 type = list(string)
}
variable "instance_types" {
  type = list(string)
}
variable "key_names" {
  type = list(string)
}
variable "block_device_name" {
  type = list(string)
}
variable "env" {
  type    = string
}
variable "project_name" {
  type = list(string)

}
variable "asg_name" {
  type = list(string)
}
variable "max_instance" {
  type    = number
}
variable "min_instance" {
  type    = number
}
variable "health_check_grace_period" {
  type    = string
}
variable "health_check_type" {
  type    = string
}
variable "desired_capacity" {
  description = "Desired capacity of something"
   type        = number
}
variable "dynamic_policy" {
  type    = string
}
variable "estimated_instance_warmup" {
  type    = number
}
variable "predefined_metric_type" {
  type    = string
}
variable "target_value" {
  type    = number
}
variable "target_group_name" {
  type = list(string)
}
variable "target_type" {
    type = string
}
variable "target_port" {
    type = number
}
variable "health_check" {
  type    = list(object({
    path          = string
    interval      = string
    protocol      = string
    matcher       = string
    timeout       = string
    unhealthy_threshold = string
    healthy_threshold   = string
   }))
}

# variable "health_path" {
#     type = list(string)
# }

variable "target_protocol" {
    type = string
}

////////////////////ALB///////////////
variable "Alb_name" {
  type    = string
}
variable "internal" {
  type = bool
}
variable "Alb_type" {
  type    = string
}
variable "enable_deletion_protection" {
  type = bool
}
/////////////ALB_listener/////////////
variable "listener_port" {
    type = number
}

variable "listener_protocol" {
    type = string
}
////////////////////////////////
variable "listener_rules" {
  type    = list(object({
    name      = string
    domain      = string
   }))
}

variable "static" {
  type = map(any)
}
