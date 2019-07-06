#!/bin/bash

# Check if script is being run by root
if [[ $EUID -ne 0 ]]; then
    "This script must be run as root!\n"
   exit 1
fi

DIVIDER="\n***************************************\n\n"

dev_user=$SUDO_USER
PHP_VERSION=7.1

# Welcome and instructions
printf $DIVIDER
printf "Installation and Configure web-development enviroment on Ubuntu 18.04\n"
printf $DIVIDER

# Prompt to continue
while true; do
	read -p "Continue [Y/N]? " cnt1
	case $cnt1 in
		[Yy]* ) break;;
		[Nn]* ) exit;;
		* ) printf "Please answer Y or N\n";;
	esac
done




# Updating and Upgrading system
printf $DIVIDER
printf "Updating and Upgrading system\n"
printf $DIVIDER

printf "Updating system\n"
apt update
printf "Repair dpkg packets\n"
dpkg --configure -a
printf "Upgrading system\n"
apt upgrade -y



# Creating a new user for developer
printf $DIVIDER
printf "Creating a new user for developer\n"
printf $DIVIDER

# Confirm the creation
while true; do
	read -p "Create a new developer user [Y/N]? " cnt1
	case $cnt1 in
		[Yy]* )
			read -p "Enter a username: " newusername
			adduser $newusername
			usermod -aG sudo $newusername
			usermod -aG www-data server-admin
			dev_user=$newusername
			break
			;;
		[Nn]* ) 
			usermod -aG www-data $dev_user			
			break;;
		* ) printf "Please answer Y or N\n";;
	esac
done


#ufw allow OpenSSH !!!!
#ufw enable

# Install Git
printf "Installing Git\n"
apt install -y git

#Install Web-Server
printf $DIVIDER
printf "Installing Web-Server\n"
printf $DIVIDER

# Install Apache web-server
printf "Installing Apache2\n"
apt install -y apache2
#ufw allow in "Apache Full"


# Configuration Apache2
printf "Configuration Apache2\n"
#printf "Enabling Apache modules...\n"
# TODO a2enmod expires headers rewrite ssl suphp mpm_prefork security2


# Changing php index file priority
printf "Making index.php the default file for directory listing\n"

if [ ! -f /etc/apache2/mods-available/dir.conf.orig ]; then
 	printf "Backing up original directory listing configuration file to /etc/apache2/mods-available/dir.conf.orig\n"
 	cp /etc/apache2/mods-available/dir.conf /etc/apache2/mods-available/dir.conf.orig
fi

printf "Editing /etc/apache2/mods-available/dir.conf\n"
FIND="index\.php "
REPLACE=""
sed -i "0,/$FIND/s/$FIND/$REPLACE/m" /etc/apache2/mods-available/dir.conf

FIND="DirectoryIndex"
REPLACE="DirectoryIndex index\.php"
sed -i "0,/$FIND/s/$FIND/$REPLACE/m" /etc/apache2/mods-available/dir.conf


# Install PHP
printf $DIVIDER
printf "Installing PHP\n"
printf $DIVIDER

if [ ! -f /etc/php/7.0/apache2/php.ini.orig ]; then
	printf "Backing up PHP.ini configuration file to /etc/php/7.0/apache2/php.ini.orig\n"
	cpphpenmod mbstring /etc/php/7.0/apache2/php.ini /etc/php/7.0/apache2/php.ini.orig
fi

printf "Installing PHP packets\n"
apt install -y php libapache2-mod-php php-mysql php-mysqli

printf "Enable PHP modules...\n"
phpenmod mbstring mysqli


# Installing MySQL
printf $DIVIDER
printf "Installing MySQL\n"
printf $DIVIDER

# Confirm MySQL Installation
while true; do
	read -p "Install MySQL [Y/N]? " cnt1
	case $cnt1 in
		[Yy]* )
			printf "Installing MySQL packets\n"
			apt install -y mysql-server
			printf "Secure MySQL installation\n"
			mysql_secure_installation
			break
			;;
		[Nn]* ) break;;
		* ) printf "Please answer Y or N\n";;
	esac
done



if [ ! -f /etc/mysql/my.cnf.orig ]; then
	printf "Backing up my.cnf configuration file to /etc/mysql/my.cnf.orig\n"
	cp /etc/mysql/my.cnf /etc/mysql/my.cnf.orig
fi


# Installing Laravel
printf $DIVIDER
printf "Installing Laravel\n"
printf $DIVIDER

# Confirm Laravel Installation
while true; do
	read -p "Install Laravel [Y/N]? " cnt1
	case $cnt1 in
		[Yy]* )
			# Installing auxiliary packets
			printf "Installing auxiliary packets before Laravel Installation\n"
			add-apt-repository -y ppa:ondrej/php
			apt-get update
			apt install -y git curl wget zip unzip
			apt install -y apache2
			apt install -y mysql-server
			apt install -y php$PHP_VERSION php$PHP_VERSION-fpm libapache2-mod-php$PHP_VERSION php$PHP_VERSION-cli php$PHP_VERSION-curl php$PHP_VERSION-mysql php$PHP_VERSION-sqlite3 php$PHP_VERSION-gd php$PHP_VERSION-xml php$PHP_VERSION-mcrypt php$PHP_VERSION-mbstring php$PHP_VERSION-iconv

			# Configure SWAP File
			printf "Configure Linux SWAP File\n"
			sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
			sudo /sbin/mkswap /var/swap.1
			sudo /sbin/swapon /var/swap.1

			# Downloading Composer
			printf "Downloading Composer\n"
			cd /home/$dev_user/
			curl -sS https://getcomposer.org/installer -o composer-setup.php
			php composer-setup.php --install-dir=/usr/local/bin --filename=composer
			rm -rf composer-setup.php
			ln /usr/local/bin/composer /usr/bin/composer
			#su $dev_user -c 'composer install'
			break
			;;
		[Nn]* ) break;;
		* ) printf "Please answer Y or N\n";;
	esac
done



# Create and Configuration sites
printf $DIVIDER
printf "Creating and Configuration sites\n"
printf $DIVIDER


while true; do
	read -p "Create a site [Y/N]? " cnt1
	case $cnt1 in
		[Yy]* ) 
			while true; do
				read -p "Please enter the main domain (e.g. example.com): " domain
				case $domain in
					"" ) printf "Domain may not be left blank\n";;
					* ) break;;
				esac
			done
			
			# Create directories
			printf "Directories for site\n"
			while true; do
				read -p "Please enter the directory path for files (e.g. /home/$dev_user/projects): " project_directory
				case $project_directory in
					"" ) printf "Project directory may not be left blank\n";;
					* ) break;;
				esac
			done
			mkdir -p $project_directory/$domain
			mkdir -p $project_directory/$domain/logs
			ln -s $project_directory/$domain /var/www
			chown -R $dev_user:$dev_user $project_directory

			# Backup previous virtual host files
			if [ -f /etc/apache2/sites-available/$domain.conf ]; then
				printf "Backing up existing virtual host configuration file to /etc/apache2/sites-available/$domain.conf.bak\n"
				cp /etc/apache2/sites-available/$domain.conf /etc/apache2/sites-available/$domain.conf.bak
			fi

			# Create Virtual Host config
			printf "Creating a Virtual Host\n"
			VIRTUALHOST="<VirtualHost *:80>\n\tServerName $domain\n\tServerAlias www.$domain\n\tDocumentRoot /var/www/$domain/\n\tErrorLog /var/www/$domain/logs/error.log\n\tCustomLog /var/www/$domain/logs/access.log combined\n</VirtualHost>\n";
			printf "$VIRTUALHOST" > /etc/apache2/sites-available/$domain.conf
			printf "127.0.0.1 $domain\n" >> /etc/hosts;


			# Create Laravel Project
			while true; do
				read -p "Create Laravel Project [Y/N]? " cnt1
				case $cnt1 in
					[Yy]* ) 
						create_laravel_project=TRUE
						cd $project_directory/$domain
						# Creating Laravel Project
						#printf "Creating Laravel Project\n"
						#su -c "composer create-project --prefer-dist laravel/laravel $domain" $dev_user
						#chown -R www-data:www-data /var/www/html/$LARAVEL_PROJECT_NAME

						# Edit file permissions
						printf "Edit file permissions\n"
						find $project_directory/$domain -type d -exec chmod 2775 {} \;
						find $project_directory/$domain -type f -exec chmod 0664 {} \;
						break
						;;
					[Nn]* ) 
						#printf "<?php phpinfo();?>" > $project_directory/$domain/info.php;
						break
						;;
					* ) printf "Please answer Y or N\n";;
				esac
			done

			

			# Enable site
			printf "Enabling site $domain\n"
			a2ensite $domain


			# Getting source code
			while true; do
				printf "Get site's source code from: \n0) Don't get source code\n1) Git\n2) URL\n"
				read -p "Enter a number (0-2): " cnt1
				case $cnt1 in
					0 ) break;;
					1 ) 
						#read -p "Enter distenation directory path (e.g. $HOME/projects/project_name)" dist_dir
						read -p "Enter Git Repository URL: " git_url
						cd $project_directory/$domain
						su -c "git init" $dev_user
						su -c "git pull --rebase $git_url master" $dev_user

						if [ $create_laravel_project ]
						then
							# Installing Composer
							printf "Installing Composer\n"
							su -c "composer install" $dev_user
							$create_laravel_project=FALSE
						fi
						break;;
					* ) printf "Please answer a number (0-2)\n";;
				esac
			done

			
			# Confirm Creation database
			while true; do
				read -p "Create a database for site [Y/N]? " cnt1
				case $cnt1 in
					[Yy]* )
						while true; do
							read -sp "Enter password for MySQL root: " mysqlrootpsw
							case $mysqlrootpsw in
								"" ) printf "Password may not be left blank\n";;
								* ) break;;
							esac
						done
						while true; do
							read -p "Enter database name (recommended: use domain without TLD, for mydomain.com use mydomain): " dbname
							case $dbname in
								"" ) printf "Database name may not be left blank\n";;
								* ) break;;
							esac
						done
						printf "Create database $dbname...\n"
						mysql -u root -p$mysqlrootpsw -e "CREATE DATABASE $dbname;"
						while true; do
							read -p "Database user (recommended: use same as database name, max 16 characters): " dbuser
							case $dbuser in
								"" ) printf "User name may not be left blank\n";;
								* ) break;;
							esac
						done
						while true; do
							read -sp "Production database password: " dbpass
							case $dbpass in
								"" ) printf "\nPassword may not be left blank\n";;
								* ) break;;
							esac
						done
						printf "Create user $dbuser...\n"
						mysql -u root -p$mysqlrootpsw -e "CREATE USER '$dbuser'@localhost IDENTIFIED BY '$dbpass';"
						printf "Grant $dbuser all privileges on $dbname...\n"
						mysql -u root -p$mysqlrootpsw -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@localhost;"

						printf "Restart MySQL...\n"
						service mysql restart
						break
						;;
					[Nn]* ) break;;
					* ) printf "Please answer Y or N\n";;
				esac
			done


			# Import database
			while true; do
				read -p "Import database from file [Y/N]? " cnt1
				case $cnt1 in
					[Yy]* ) 
						read -p "Enter a sql export file path (e.g. $HOME/projects/project_name/db_backup.sql)" import_dbfile
						mysql -u $dbuser --password=$dbpass $dbname < $import_dbfile
						break
						;;
					[Nn]* ) break;;
					* ) printf "Please answer Y or N\n";;
				esac
			done
			continue
			;;
		[Nn]* ) break;;
		* ) printf "Please answer Y or N\n";;
	esac
done

printf "Disable default virtual host...\n"
a2dissite 000-default.conf

printf "Owner www-data:www-data to /var/www\n"
chown -R www-data:www-data /var/www

printf "Restart Apache2\n"
service apache2 reload


# Installing phpmyadmin
printf "Installing phpmyadmin...\n"
apt install -y phpmyadmin php-mbstring php-gettext
phpenmod mbstring


exit
