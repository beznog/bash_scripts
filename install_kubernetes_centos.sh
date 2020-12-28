#!/bin/bash

#Parameters
role=$1
master_ip=$2
worker_ip=$3
worker_init_command=$4

#Variables
master_name="master-node"
worker_name_1="node-1"
worker_name_2="worker_node_1"

#Update Yum Packeges
yum update

#Install and Start Docker
printf "##### Installing Docker #####\n"
yum install -y docker
systemctl enable docker
systemctl start docker

#Add Kubernetes Repository
printf "##### Adding Kubernetes Repository #####\n"
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

#Disable SeLinux
printf "##### Disabling SeLinux #####\n"
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

#Add Firewall-Rules to Ports
printf "##### Adding Firewall Rules #####\n"
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --reload

#Firewall modules reload
printf "##### Enabling Firewalls Modules #####\n"
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

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
	echo "$master_ip $mster_name" >> /etc/hosts
elif [ $worker_ip ]; then
	printf "##### Add Worker hostname to /etc/hosts #####\n"
	echo "$worker_ip $worker_name_1 $worker_name_2" >> /etc/hosts
else
	printf "No Nodes IPs\n"
fi

#Install and Start Kubernetes:
printf "##### Installing Kubernetes #####\n"
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet
systemctl start kubelet

#Disable SWAP:
printf "##### Disabling SWAP #####\n"
swapoff -a
$FIND="/dev/mapper/centos-swap swap swap defaults 0 0"
$REPLACE="#$FIND"
sed -i "0,/$FIND/s/$FIND/$REPLACE/m" /etc/fstab

printf "##### Kubernetes Initialization #####\n"
if [ $role = "master" ]; then
	printf "##### Master-node Init #####\n"
	kubeadm init --pod-network-cidr=10.244.0.0/16
	mkdir -p $HOME/.kube
	cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	chown $(id -u):$(id -g) $HOME/.kube/config
	kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
elif [$role = worker]; then
	printf "##### Worker-node Init #####\n"
	bash $worker_init_command
fi
