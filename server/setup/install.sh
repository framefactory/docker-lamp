#!/bin/bash
# Install LAMP stack on Ubuntu 16.04

# Variables
#MYSQL_ROOT_PASS=password
#PHPMYADMIN_APP_PASS=password

# create app data directories
mkdir -p /app/www
mkdir -p /app/db
mkdir -p /app/log

# APACHE ---------------------------------------------------

# Apache server
apt-get install -y apache2

cat <<EOT >> /etc/apache2/apache2.conf
ServerName webserver.local
EOT

cat <<EOT > /etc/apache2/sites-available/001-webserver.conf
<VirtualHost *:80>
    ServerName webserver.local
    ServerAdmin admin@webserver.local
    ServerAlias www.webserver.local

    LogLevel warn
    ErrorLog /app/log/webserver/error.log
    CustomLog /app/log/webserver/access.log combined

    DocumentRoot /app/www

    <Directory /app/www>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOT

# Enable new website
a2dissite 000-default
a2ensite 001-webserver

# Apache modules
a2enmod rewrite

# MYSQL ----------------------------------------------------

# MySQL server - silent install
debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASS"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASS"
apt-get -y install mysql-server

# copy db data
cp -R /var/lib/mysql /app/db
mv /var/lib/mysql /var/lib/mysql.bak
chown -R mysql:mysql /app/db/mysql

# Copy and edit MySQL config file
rm /etc/mysql/my.cnf
cp /etc/alternatives/my.cnf /etc/mysql/my.cnf

cat <<EOT >> /etc/mysql/my.cnf
[mysqld]
  datadir=/app/db/mysql
EOT

# Set MySQL user home directory to new location
usermod -d /app/db/mysql mysql

# PHP ------------------------------------------------------

# PHP with Apache lib and MySQL API
apt-get install -y php libapache2-mod-php php-mcrypt php-mysql

# CONFIGURATION --------------------------------------------

# Start Apache2 and MySQL
service apache2 start
service mysql start

# Harden MySQL security
myql --user=root <<_EOF_
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF_

# PHPMYADMIN -----------------------------------------------

# PhpMyAdmin silent installation
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-user string root"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $MYSQL_ROOT_PASS"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASS"
debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASS"
apt-get -y install phpmyadmin