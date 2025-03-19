#!/bin/bash

# Variables
MYSQL_ROOT_PASSWORD="Password_123"
MYSQL_ADMIN_USER="admin"
MYSQL_ADMIN_PASSWORD="Password_123"
MYSQL_CONF_FILE="/etc/mysql/mysql.conf.d/mysqld.cnf" # Or /etc/mysql/my.cnf depending on your system

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

# Change bind-address in MySQL configuration file
sudo sed -i 's/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' "$MYSQL_CONF_FILE"

# Restart MySQL service
sudo systemctl restart mysql

# Print completion message
echo "MySQL installation, user setup, and bind-address change completed successfully."
