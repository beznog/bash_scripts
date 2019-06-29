#!/bin/bash
USERNAME=burov-net
PHP_VERSION=7.1
SERVER_GROUPNAME=burov-net
LARAVEL_PROJECT_NAME=lara_test_app
SITE_NAME=laravel
SERVER_NAME=beznog.com
DOCUMENT_ROOT=/var/www/html/$LARAVEL_PROJECT_NAME/public


sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y git curl wget zip unzip
sudo apt-get install -y apache2
sudo apt-get install -y mysql-server

sudo apt install -y php$PHP_VERSION php$PHP_VERSION-fpm libapache2-mod-php$PHP_VERSION php$PHP_VERSION-cli php$PHP_VERSION-curl php$PHP_VERSION-mysql php$PHP_VERSION-sqlite3 php$PHP_VERSION-gd php$PHP_VERSION-xml php$PHP_VERSION-mcrypt php$PHP_VERSION-mbstring php$PHP_VERSION-iconv


sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
sudo /sbin/mkswap /var/swap.1
sudo /sbin/swapon /var/swap.1


su $USERNAME -c 'cd ~ && curl -sS https://getcomposer.org/installer | php'
sudo mv composer.phar /usr/local/bin/composer
sudo ln -s /usr/local/bin/composer /usr/bin/composer
su $USERNAME -c 'composer install'

cd /var/www/html
chown -Rv www-data:$SERVER_GROUPNAME /var/www
chmod -Rv g+rw /var/www

su $USERNAME -c "composer create-project --prefer-dist laravel/laravel $LARAVEL_PROJECT_NAME"

chown -R www-data:www-data /var/www/html/$LARAVEL_PROJECT_NAME

find /var/www/html/$LARAVEL_PROJECT_NAME -type d -exec chmod 2775 {} \;
find /var/www/html/$LARAVEL_PROJECT_NAME -type f -exec chmod 0664 {} \;

sudo echo "<VirtualHost *:80>
ServerAdmin admin@$SERVER_NAME
DocumentRoot $DOCUMENT_ROOT
ServerName $SERVER_NAME

<Directory $DOCUMENT_ROOT>
Options +FollowSymlinks
AllowOverride All
Require all granted
</Directory>

ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" > /etc/apache2/sites-available/$SITE_NAME.conf
sudo a2enmod rewrite
sudo a2ensite $SITE_NAME.conf
sudo a2dissite 000-default.conf
systemctl restart apache2.service
