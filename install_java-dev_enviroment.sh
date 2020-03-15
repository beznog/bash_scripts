#!/bin/bash

# Check if script is being run by root
if [[ $EUID -ne 0 ]]; then
    "This script must be run as root!\n"
   exit 1
fi

DIVIDER="\n***************************************\n\n"

dev_user=$SUDO_USER

# Welcome and instructions
printf $DIVIDER
printf "Installation and Configure Java-development enviroment (JRE11+JRE8+IntelliJ IDEA) on Ubuntu 18.04\n"
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
			usermod -aG java-admin
			dev_user=$newusername
			break
			;;
		[Nn]* ) 	
			break;;
		* ) printf "Please answer Y or N\n";;
	esac
done


# Installing Sikuli Enviroment
printf $DIVIDER
printf "Installing Sikuli\n"
printf $DIVIDER

# Confirm Sikuli Installation
while true; do
	read -p "Install Sikuli [Y/N]? " cnt1
	case $cnt1 in
		[Yy]* )
			# Download Sikuli
			su -c "cd ~/Downloads" $dev_user
			printf "Downloading Sikuli API File\n"
			su -c "wget https://launchpad.net/sikuli/sikulix/2.0.3/+download/sikulixapi-2.0.3.jar" $dev_user


			# Installing libraries for Sikuli
			printf "Installing libraries for Sikuli\n"
			apt install libopencv-dev
			apt install libtesseract-dev

			if [ ]; then
			# BEGIN OF COMMENT BLOCK
# Installing openCV 4.1.1
			printf "Installing openCV 4.1.1\n"
			apt-get install -y build-essential cmake git wget unzip yasm pkg-config libswscale-dev libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libavformat-dev libpq-dev
			rm -rf /var/lib/apt/lists/*
			
			# Downloading and Extracting OpenCV
			printf "Downloading and Extracting OpenCV\n"
			OPENCV_VERSION="4.1.1"
			cd /home/$dev_user/
			wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip
			unzip ${OPENCV_VERSION}.zip
			
			# Configurate and Build OpenCV
			printf "Configurate and Build OpenCV\n"
			mkdir opencv-${OPENCV_VERSION}/cmake_binary
			cd opencv-${OPENCV_VERSION}/cmake_binary
			cmake -DBUILD_TIFF=ON -DBUILD_opencv_java=ON -DWITH_CUDA=OFF -DWITH_OPENGL=ON -DWITH_OPENCL=ON -DWITH_IPP=ON -DWITH_TBB=ON -DWITH_EIGEN=ON -DWITH_V4L=ON -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DCMAKE_BUILD_TYPE=RELEASE ..
			make install

			# Delete OpenCV Download Files
			cd /home/$dev_user/
			rm ${OPENCV_VERSION}.zip
			rm -r opencv-${OPENCV_VERSION}
			# END OF COMMENT BLOCK
			fi

			# Linking OpenCV
			sudo ln -s /usr/lib/jni/libopencv_java320.so /usr/lib/libopencv_java.so

			break
			;;
		[Nn]* ) break;;
		* ) printf "Please answer Y or N\n";;
	esac
done

# Installing IntelliJ IDEA
printf $DIVIDER
printf "Installing IntelliJ IDEA\n"
printf $DIVIDER

# Confirm IntelliJ IDEA Installation
while true; do
	read -p "Install IntelliJ IDEA [Y/N]? " cnt1
	case $cnt1 in
		[Yy]* )
			# Download and Installing IntelliJ IDEA
			cd /home/$dev_user/Downloads
			printf "Downloading IntelliJ IDEA\n"
			su -c "wget https://download.jetbrains.com/idea/ideaIC-2019.3.3.tar.gz" $dev_user
			printf "Extracting files\n"
			su -c "tar xzf ideaIC-2019.3.3.tar.gz" $dev_user
			printf "Starting IntelliJ IDEA Install script\n"
			su -c "idea-IC-193.6494.35/bin/idea.sh" $dev_user
			break
			;;
		[Nn]* ) break;;
		* ) printf "Please answer Y or N\n";;
	esac
done
