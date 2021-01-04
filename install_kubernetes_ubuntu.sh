#!/bin/bash

#Parameters
role=$1
master_ip=$2
worker_ip=$3
worker_init_command=$4

#Variables
master_name="master-node"
worker_name_1="node-1"
worker_name_2="worker-node-1"

#Update apt Packages
printf "##### Updating apt Packages #####\n"
apt update -y

#Upgrade apt Packages
printf "##### Upgrading apt Packages #####\n"
apt upgrade -y

#Install and Start Docker
printf "##### Installing Docker #####\n"
apt-get install -y docker.io
apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt-get update
apt-cache policy docker-ce
apt-get install docker-ce

systemctl start docker
systemctl enable docker

#Add Kubernetes Repository
printf "##### Adding Kubernetes Repository #####\n"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update

apt-get install -y kubelet kubeadm kubectl
apt-get install keepalived
systemctl enable keepalived
systemctl start keepalived



#Add Firewall-Rules to Ports
printf "##### Adding Firewall Rules #####\n"
apt-get install firewalld
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --permanent --add-port=8285/udp
firewall-cmd --permanent --add-port=8472/udp
firewall-cmd --permanent --add-port=179/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --reload

#Deactivate Firewall
printf "##### Deactivatind Firewall #####\n"
ufw disable
systemctl start firewalld
systemctl enable firewalld
#systemctl stop firewalld
#systemctl disable firewalld

#Clear Iptables
#printf "##### Clearing Iptables #####\n"
#iptables --flush
#iptables -tnat --flush

#Firewall modules reload
#printf "##### Enabling Firewalls Modules #####\n"
#modprobe br_netfilter
#echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
sysctl net.bridge.bridge-nf-call-iptables=1


#Edit hostnames file
printf "##### Editing hostnames #####\n"
if [ $role = "master" ]; then
	printf "Set Master hostname\n"
	hostnamectl set-hostname $master_name
elif [ $role = "worker" ]; then
	printf "Set Worker hostname\n"
	hostnamectl set-hostname $worker_name_1
else
	printf "No Hostname\n"
fi

if [ $master_ip ]; then
	printf "##### Add Master hostname to /etc/hosts #####\n"
	echo "$master_ip $master_name" >> /etc/hosts
fi
if [ $worker_ip ]; then
	printf "##### Add Worker hostname to /etc/hosts #####\n"
	echo "$worker_ip $worker_name_1 $worker_name_2" >> /etc/hosts
else
	printf "No Nodes IPs\n"
fi

#Install and Start Kubernetes:
#printf "##### Installing Kubernetes #####\n"
#yum install -y kubelet kubeadm
#if [ $role = "master" ]; then
#        printf "Install kubectl only for Master\n"
#        yum install -y kubectl
#fi
#systemctl enable kubelet
#systemctl start kubelet

#Disable SWAP:
printf "##### Disabling SWAP #####\n"
swapoff -a
#FIND="\/dev\/mapper\/centos-swap"
#REPLACE="#$FIND"
#sed -i "0,/$FIND/s/$FIND/$REPLACE/m" /etc/fstab
#sed -i "0,/\/dev\/mapper\/centos-swap/s/\\/dev\/mapper\/centos-swap/#\/dev\/mapper\/centos-swap/m" /etc/fstab


printf "##### Kubernetes Initialization #####\n"
if [ $role = "master" ]; then
	printf "##### Master-node Init #####\n"
#	kubeadm init --pod-network-cidr=10.244.0.0/16 > kubernetes_init_output.txt
	kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.0.214
	mkdir -p $HOME/.kube
	cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	chown $(id -u):$(id -g) $HOME/.kube/config
	kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml
elif [ $role = "worker" ]; then
	printf "##### Worker-node Init #####\n"
	eval "$worker_init_command"
fi

reboot
