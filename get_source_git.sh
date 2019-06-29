#!/bin/bash

# Getting source code
while true; do
	printf "Get site's source code from: \n0) Don't get source code\n1) Git\n2) URL\n"
	read -p "Enter a number (0-2): " cnt1
	case $cnt1 in
		0 ) break;;
		1 ) 
			read -p "Enter distenation directory path (e.g. $HOME/projects/project_name)" dist_dir
			read -p "Enter Git Repository URL: " git_url
			read -p "Enter web-dev username: " dev_user
			cd $dist_dir
			su -c "git init" $dev_user
			su -c "git pull --rebase $git_url master" $dev_user
			break;;
		* ) printf "Please answer a number (0-2)\n";;
	esac
done
