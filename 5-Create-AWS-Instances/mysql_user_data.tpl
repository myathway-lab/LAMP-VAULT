#!/bin/bash
set -e
sudo hostnamectl set-hostname LAMP-MySQL
sudo apt-get update -y
sudo apt-get install mysql-server -y
# Secure MySQL installation
sudo mysql_secure_installation <<SECURE_EOF
y
0
y
y
y
y
SECURE_EOF

# Login to MySQL with root user and empty password, then change the root password
# root_password="${mysql_root_password}"

root_password=var.mysql_root_password

sudo mysql -u root --execute="ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$root_password'; FLUSH PRIVILEGES;"

# Run additional MySQL commands
lamp_password=var.mysql_lamp_password
sudo mysql -u root -p"$root_password" <<MYSQL_EOF
CREATE DATABASE lamp;
CREATE USER 'lampuser'@'%' IDENTIFIED BY '$lamp_password';
GRANT ALL PRIVILEGES ON lamp.* TO 'lampuser'@'%';
GRANT DROP ON mysql.* TO 'lampuser'@'%' WITH GRANT OPTION;
GRANT CREATE USER ON *.* TO 'lampuser'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_EOF


# Change the bind address to all to accept remote connection.
sudo sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

# Restart the mysql after config change.
sudo systemctl restart mysql