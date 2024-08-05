resource "aws_security_group" "rds_sg" {
  name        = var.rds_sg_name
  vpc_id      = var.vpc_id
  ingress {
    description = "for database access"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "TCP"
    cidr_blocks = var.db_cidr_blocks
  }
  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  } 
  tags = merge(var.tags)
}

resource "aws_instance" "db_server" {
  instance_type               = lookup(var.db_instance_config, "itype")
  subnet_id                   = var.private_subnet_ids[2]
  ami                         = lookup(var.db_instance_config, "ami")
  associate_public_ip_address = lookup(var.db_instance_config, "publicip")
  key_name                    = lookup(var.db_instance_config, "keyname")
  vpc_security_group_ids      = [aws_security_group.rds_sg.id]

  # User data script to run on instance startup
  user_data = <<-EOF
    #!/bin/bash

    # Variables
    MYSQL_ROOT_PASSWORD="Password_123"
    MYSQL_ADMIN_USER="admin"
    MYSQL_ADMIN_PASSWORD="Password_123"

    # Update package lists
    apt update -y

    # Install MySQL Server
    DEBIAN_FRONTEND=noninteractive apt install mysql-server -y

    # Wait for MySQL service to be ready
    until systemctl is-active --quiet mysql; do
      echo "Waiting for MySQL to start..."
      sleep 5
    done

    # Secure MySQL installation
    mysql --execute="ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';"
    mysql --execute="FLUSH PRIVILEGES;"

    # Create a new admin user with access from anywhere
    mysql --user=root --password="${MYSQL_ROOT_PASSWORD}" --execute="CREATE USER '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ADMIN_PASSWORD}';"
    mysql --user=root --password="${MYSQL_ROOT_PASSWORD}" --execute="GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'%' WITH GRANT OPTION;"
    mysql --user=root --password="${MYSQL_ROOT_PASSWORD}" --execute="FLUSH PRIVILEGES;"

    # Print completion message
    echo "MySQL installation and user setup completed successfully."
  EOF

  tags = merge(
    {
      "Name" = format("%s-Db-Mysql", var.name)
    },
    var.tags
  )
}

#===============RDS======================# 
# resource "aws_db_subnet_group" "rds_subnet_group" {
#   name       = var.db_subnet_group_name
#   subnet_ids = var.private_subnet_ids
#   # subnet_ids = [
#   #   data.aws_subnet.az1_subnet.id,
#   #   data.aws_subnet.az2_subnet.id,
#   # ]
#   tags = merge(var.tags)
# }

# resource "aws_db_instance" "en_database" {
#   allocated_storage                   = var.db_instance_config.allocated_storage
#   max_allocated_storage               = var.db_instance_config.max_allocated_storage
#   storage_type                        = var.db_instance_config.storage_type
#   identifier                          = var.db_instance_config.identifier
#   engine                              = var.db_instance_config.engine_name
#   engine_version                      = var.db_instance_config.engine_version
#   instance_class                      = var.db_instance_config.instance_class
#   username                            = var.db_instance_config.username
#   password                            = var.db_instance_config.password
#   iam_database_authentication_enabled = var.db_instance_config.iam_database_authentication_enabled
#   multi_az                            = var.db_instance_config.multi_az
#   performance_insights_enabled        = var.db_instance_config.performance_insights_enabled
#   deletion_protection                 = var.db_instance_config.deletion_protection
#   publicly_accessible                 = var.db_instance_config.public_access
#   vpc_security_group_ids              = [aws_security_group.rds_sg.id]
#   db_subnet_group_name                = aws_db_subnet_group.rds_subnet_group.name
#   availability_zone                   = var.db_instance_config.availability_zone
#   port                                = var.db_instance_config.port
#   parameter_group_name                = var.db_instance_config.parameter_group_name
#   backup_retention_period             = var.db_instance_config.backup_retention_period
#   backup_window                       = var.db_instance_config.backup_window
#   maintenance_window                  = var.db_instance_config.maintenance_window
#   delete_automated_backups            = var.db_instance_config.delete_automated_backups
#   skip_final_snapshot                 = var.db_instance_config.skip_final_snapshot
#    tags = merge(var.tags)
# }

























# resource "aws_db_instance" "en_database" {
#  allocated_storage                   = 150
#   max_allocated_storage               = 200
#   storage_type                        = "gp3"
#   identifier                          = var.identifier
#   engine                              = "mysql"
#   engine_version                      = "8.0"
#   instance_class                      = "db.m5.large"
#   username                            = "admin"
#   password                            = "admin123"
#   iam_database_authentication_enabled = true
#   multi_az                            = false
#   performance_insights_enabled        = true
#   deletion_protection                 = false
#   publicly_accessible                 = false
#   vpc_security_group_ids              = [aws_security_group.rds_sg.id]
#   db_subnet_group_name                = aws_db_subnet_group.default.name
#   availability_zone                   = "us-east-1a"
#   port                                = 3306
#   parameter_group_name                = "default.mysql8.0"
#   backup_retention_period             = 7
#   backup_window                       = "03:00-04:00"
#   maintenance_window                  = "Sun:00:00-Sun:03:00"
#   skip_final_snapshot                 = true
#   tags = {
#     Name = "MyDatabaseInstance"
#   }
# }

# # resource "aws_db_instance" "en-database" {

# #   db_name               = "mydb"
# #   engine                = "mysql"
# #   engine_version        = "8.0.35"
# #   username              = "foo"
# #   password              = "foobarbaz"
# #   instance_class        = "db.t3.micro"
# #   multi_az              = false # make it True if you want HA (two db instances in diff az running parlaly) 
# #   storage_type          = "gp3"
# #   allocated_storage     = 150
# #   max_allocated_storage = 200
# #   #   ca_cert_identifier = "rds-ca-rsa2048-g1"
# #   performance_insights_enabled = true
# #   #   parameter_group_name = "default.mysql8.0"
# #   #   backup_retention_period = 7           # Number of days to retain automated backups
#   #   backup_window = "03:00-04:00" 
#   #   delete_automated_backups = true

#   #   skip_final_snapshot  = false
#   deletion_protection = false
# }


#   publicly_accessible =  false
#   vpc_security_group_ids = [aws_security_group.rds_sg.id]
#   db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
#   availability_zone =   "us-east-1a"
#   port                 = 3306

# data "aws_subnets" "default" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.default.id]
#   }
# }

# Fetching subnets from two different AZs
# data "aws_subnet" "az1_subnet" {
#   vpc_id            = data.aws_vpc.default.id
#   availability_zone = "us-east-1a"  # Adjust if needed
# }

# data "aws_subnet" "az2_subnet" {
#   vpc_id            = data.aws_vpc.default.id
#   availability_zone = "us-east-1b"  # Adjust if needed
# }
