#!/bin/bash

# Install Text Editor Sublime Text 3 with Plugins
printf "Installing Sublime Text 3\n"
while true; do
	read -p "Install Text Editor Sublime Text 3 with Plugins [Y/N]? " cnt1
	case $cnt1 in
		[Yy]* ) 
			wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
			apt-get install -y apt-transport-https
			echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
			apt-get update
			apt-get install -y sublime-text
			apt install -y nodejs
			apt install -y npm
			npm install -g jshint
			mkdir -p $HOME/.config/sublime-text-3/Packages/User
			echo '{ "installed_packages": [	"Alignment","All Autocomplete","BracketHighlighter","Emmet","Git","HTML-CSS-JS Prettify","SFTP","SideBarEnhancements","SublimeLinter","SublimeLinter-jshint","SublimeLinter-phplint","Material Theme","Theme - Brogrammer"] }' > "$HOME/.config/sublime-text-3/Packages/User/Package Control.sublime-settings"
			mkdir -p "$HOME/.config/sublime-text-3/Packages/Alignment"
			mkdir -p "$HOME/.config/sublime-text-3/Installed Packages"
			wget "https://packagecontrol.io/Package%20Control.sublime-package" -O "$HOME/.config/sublime-text-3/Installed Packages/Package Control.sublime-package"
			chown -R $SUDO_USER:$SUDO_USER $HOME/.config/sublime-text-3/
			break
			;;
		[Nn]* ) break;;
		* ) printf "Please answer Y or N\n";;
	esac
done


