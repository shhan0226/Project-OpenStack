#!/bin/bash

##################################
# root 권한으로 변경하세요
##################################

IAMACCOUNT=$(whoami)
echo "${IAMACCOUNT}"

if [ "$IAMACCOUNT" = "root" ]; then
        echo "It's root account."
else
        echo "It's not a root account."
        exit 100
fi

##################################
# create flavor(Instance TEMP)
##################################
. admin-openrc

echo "create flavor"
openstack flavor create --vcpus 2 --ram 2048 --disk 15 arm-flavor

echo "flavor list"
openstack flavor list


##################################
# create img
##################################
. admin-openrc

echo "image create"
# openstack image create --disk-format qcow2 --file ./CentOS-7-x86_64-GenericCloud.qcow2 centos7
openstack image create "ubuntu1804" --file ./bionic-server-cloudimg-amd64.img --disk-format qcow2 --public

echo "image show"
openstack image show ubuntu1804

sync

##################################
# create Instance
##################################
. arm-openrc

openstack server list

read -p "Input VM Name: " VM_NAME
sync
echo "${VM_NAME}"
sync

echo "server create"

. arm-openrc

openstack server create --image ubuntu1804 --flavor arm-flavor --key-name arm-key --network internal --user-data init.sh --security-group arm-secu ${VM_NAME}

echo "server list"
openstack server list



##################################
# Add Floating IP
##################################
. arm-openrc

echo "floating ip create"
openstack floating ip create external

read -p "Input floating IP: " F_IP
sync
echo "${VM_NAME} ${F_IP}"

echo "server add floating ip"
openstack server add floating ip ${VM_NAME} ${F_IP}

chmod 400 arm-key.pem
echo "================================="
echo "ssh -i arm-key.pem ubuntu@${F_IP}"
echo "================================="
echo "END..."
