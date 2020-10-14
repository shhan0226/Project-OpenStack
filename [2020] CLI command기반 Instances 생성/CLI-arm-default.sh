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
# download img
##################################
apt install wget -y
#wget http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2
#wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-arm64.img

##################################
# . admin_openrc
##################################
. admin-openrc


##################################
# create project
##################################
sync

. admin-openrc

echo "openstack project list..."
openstack project list



##################################
# create External Net
##################################
. admin-openrc

echo "external net"
openstack network create --external --provider-network-type flat --provider-physical-network provider external


##################################
# create Subnet External Net
##################################
. admin-openrc

ifconfig
sync
read -p "External Subnet range: (ex 10.0.10.0/24) " SUBNET_RANGE
sync

read -p "External Start IP: (ex 10.0.10.100) " START_IP
sync

read -p "External End IP: (ex 10.0.10.200) " END_IP
sync

read -p "External Gateway IP: " GATEWAY_IP
sync

echo "external sub net..."
openstack subnet create --subnet-range ${SUBNET_RANGE} --no-dhcp --gateway ${GATEWAY_IP} --network external --allocation-pool start=${START_IP},end=${END_IP} external-subnet

sync

##################################
# create Internal Net
##################################
. demo-openrc

echo "internal net..."
openstack network create internal

sync
##################################
# create Subnet Internal Net
##################################
. demo-openrc

read -p "Internal Subnet range: (ex 172.10.0.0/24) " SUBNET_RANGE2
sync

echo "insternal sub net..."
openstack subnet create --subnet-range ${SUBNET_RANGE2} --dhcp --network internal --dns-nameserver 8.8.8.8 internal-subnet

sync

##################################
# create Router
##################################
. demo-openrc

echo "route create..."
openstack router create arm-router

echo "route in add..."
openstack router add subnet arm-router internal-subnet

echo "route ex add..."
openstack router set --external-gateway external arm-router

echo "route list..."
openstack router list

sync


##################################
# create keypair
##################################
. demo-openrc

echo "keypair list..."
openstack keypair list
openstack keypair create arm-key > arm-key.pem


##################################
# create Secu.
##################################
. demo-openrc

echo "security list..."
openstack security group create arm-secu

openstack security group rule create --remote-ip 0.0.0.0/0 --dst-port 22 --protocol tcp --ingress arm-secu

openstack security group rule create --remote-ip 0.0.0.0/0 --dst-port 80 --protocol tcp --ingress arm-secu

openstack security group rule create --remote-ip 0.0.0.0/0 --protocol icmp --ingress arm-secu

openstack security group show arm-secu


##################################
# create init.sh
##################################
. demo-openrc

cat << EOF >init.sh
#cloud-config
password: stack
chpasswd: { expire: False }
ssh_pwauth: True
EOF












