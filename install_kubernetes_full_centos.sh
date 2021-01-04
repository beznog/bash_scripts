#!/bin/bash

# Variables
ssh_user="root"
master_ip=$1
worker_ip=$2
script_path_source="/home/burov/bash_scripts"
script_path_destination="/root"
script_name="install_kubernetes_node_centos.sh"
init_command_filename="kubernetes_worker_init_command.txt"
deployment_path_source="/home/burov/projects/k8s/deployments"
laravel_deployment_filename="deployment_laravel.yml"
mysql_deployment_filename="deployment_mysql.yml"

# Install on Master
scp $script_path_source/$script_name $ssh_user@$master_ip:$script_path_destination/$script_name
ssh $ssh_user@$master_ip "bash $script_path_destination/$script_name master $master_ip $worker_ip"
sleep 30

# Copy Worker-Init Command from Master to Local
scp $ssh_user@$master_ip:$script_path_destination/$init_command_filename .
init_command=$(cat $init_command_filename | tr -d '\\\n')
echo $init_command
rm -rf $init_command_filename

# Install on Worker
scp $script_path_source/$script_name $ssh_user@$worker_ip:$script_path_destination/$script_name
ssh $ssh_user@$worker_ip "bash $script_path_destination/$script_name worker $master_ip $worker_ip \"$init_command\""
sleep 180

# Apply Deployments
scp $deployment_path_source/* $ssh_user@$master_ip:$script_path_destination/
ssh $ssh_user@$master_ip "kubectl apply -f $mysql_deployment_filename"
ssh $ssh_user@$master_ip "kubectl apply -f $laravel_deployment_filename"
