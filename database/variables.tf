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
variable "db_subnet_group_name" {
  type = string
}

variable "db_instance_config" {
  description = "Configuration map for the RDS instance."
  type        = map(any)
  default = {
    allocated_storage                   = 50
    max_allocated_storage               = 100
    storage_type                        = "gp3"
    identifier                          = "IBAI-DB-MYSQL"
    engine_name                         = "mysql"
    engine_version                      = "8.0"
    instance_class                      = "db.t3.micro"
    username                            = "admin"
    password                            = "password123"
    iam_database_authentication_enabled = true
    multi_az                            = false
    performance_insights_enabled        = true
    deletion_protection                 = false
    public_access                       = false
    availability_zone                   = "us-east-1a"
    port                                = 3306
    parameter_group_name                = "default.mysql8.0"
    backup_retention_period             = 7
    backup_window                       = "03:00-04:00"
    maintenance_window                  = "Sun:05:00-Sun:06:00"
    delete_automated_backups            = true
    skip_final_snapshot                 = true
  }
}
