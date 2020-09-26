#!/bin/bash

read -p "What is openstack passwrd? : " STACK_PASSWD
echo "$STACK_PASSWD"

ifconfig
read -p "Input IP: " SET_IP
echo "$SET_IP"
sync

##########################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "Service Install ..."
apt install openstack-dashboard -y

crudini 



