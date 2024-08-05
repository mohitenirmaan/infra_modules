#!/bin/bash

# Variables
MYSQL_ROOT_PASSWORD="Password_123"
MYSQL_ADMIN_USER="admin_user"
MYSQL_ADMIN_PASSWORD="Password_123"

# Update package lists
sudo apt update -y

# Install MySQL Server
sudo apt install mysql-server -y

# Secure MySQL installation
sudo mysql --execute="ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';"
sudo mysql --execute="FLUSH PRIVILEGES;"

# Create a new admin user with access from anywhere
sudo mysql --user=root --password="${MYSQL_ROOT_PASSWORD}" --execute="CREATE USER '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ADMIN_PASSWORD}';"
sudo mysql --user=root --password="${MYSQL_ROOT_PASSWORD}" --execute="GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'%' WITH GRANT OPTION;"
sudo mysql --user=root --password="${MYSQL_ROOT_PASSWORD}" --execute="FLUSH PRIVILEGES;"

# Print completion message
echo "MySQL installation and user setup completed successfully."
