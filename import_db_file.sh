#!/bin/bash

# Import database
while true; do
	read -p "Import database from file [Y/N]? " cnt1
	case $cnt1 in
		[Yy]* ) 
			read -p "Enter database name: " dbname
			read -p "Enter database username: " dbuser
			read -sp "Enter password of $dbuser: " dbpass
			
			read -p "Enter a sql export file path (e.g. $HOME/projects/project_name/db_backup.sql)" import_dbfile
			mysql -u $dbuser --password=$dbpass $dbname < $import_dbfile
			break				
			;;
		[Nn]* ) break;;
		* ) printf "Please answer Y or N\n";;
	esac
done
