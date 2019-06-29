#!/bin/bash

# Installing ang Configurating Firefox
while true; do
	read -p "Install and configure Firefox [Y/N]? " cnt1
	case $cnt1 in
		[Yy]* ) 
			printf "Installing Firefox\n"
			apt install firefox

			printf "Disabled Hardware Acceleration\n"
			firefox_settings_dir=$HOME/.mozilla/firefox
			echo 'user_pref("layers.acceleration.disabled", true);' > $firefox_settings_dir/$(ls $firefox_settings_dir | grep ".default-release")/prefs.js
			
			printf "Install Adobe Flash Player\n"
			printf "Downloading archive\n"
			su -c 'wget "https://fpdownload.adobe.com/get/flashplayer/pdc/32.0.0.207/flash_player_npapi_linux.x86_64.tar.gz" -O $HOME/Downloads/flashplayer.tar.gz' $SUDO_USER
			printf "Create directory to extract\n"
			su -c "mkdir -p $HOME/Downloads/flashplayer" $SUDO_USER
			cd $HOME/Downloads/flashplayer
			printf "Extracting archive\n"
			su -c "tar -zxvf ../flashplayer.tar.gz" $SUDO_USER
			printf "Coping files to system\n"
			cp libflashplayer.so /usr/lib/mozilla/plugins
			printf "Removing temp files\n"
			cd ..
			rm -rf flashplayer flashplayer.tar.gz
			printf "Starting Firefox Account Manager\nChoose default-release Profile and start Firefox!\n"
			su -c "firefox --ProfileManager" $SUDO_USER &
			break				
			;;
		[Nn]* ) break;;
		* ) printf "Please answer Y or N\n";;
	esac
done

