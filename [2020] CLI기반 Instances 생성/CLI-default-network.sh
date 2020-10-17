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
wget http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2
wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img

##################################
# . admin_openrc
##################################
. admin-openrc


##################################
# . arm-openrc
##################################
sync

cat << EOF > arm-openrc
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=arm-project
export OS_USERNAME=arm-user
export OS_PASSWORD=stack
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF


##################################
# create project
##################################
sync

. admin-openrc

echo "openstack project list"
openstack project list

echo "project create arm-project"
openstack project create arm-project

echo "openstack project list"
openstack project list


##################################
# create user
##################################
. admin-openrc

echo "create user & add role"
openstack user create --project arm-project --password stack arm-user

echo "role list"
openstack role list

echo "role add"
openstack role add --project arm-project --user arm-user member

echo "arm-user show"
openstack user show arm-user


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

echo "external sub net"
openstack subnet create --subnet-range ${SUBNET_RANGE} --no-dhcp --gateway ${GATEWAY_IP} --network external --allocation-pool start=${START_IP},end=${END_IP} --dns-nameserver 8.8.8.8 external-subnet

sync

##################################
# create Internal Net
##################################
. admin-openrc

echo "internal net"
openstack network create internal

sync
##################################
# create Subnet Internal Net
##################################
. admin-openrc

read -p "Internal Subnet range: (ex 172.10.0.0/24) " SUBNET_RANGE2
sync

echo "insternal sub net"
openstack subnet create --subnet-range ${SUBNET_RANGE2} --dhcp --network internal --dns-nameserver 8.8.8.8 internal-subnet

sync

##################################
# create Router
##################################
. admin-openrc

echo "route create"
openstack router create arm-router

echo "route in add"
openstack router add subnet arm-router internal-subnet

echo "route ex add"
openstack router set --external-gateway external arm-router

echo "route list"
openstack router list

sync


##################################
# create keypair
##################################
. admin-openrc
echo "keypair list"
openstack keypair list
openstack keypair create arm-key > arm-key.pem


##################################
# create Secu.
##################################
. admin-openrc

echo "security list"
openstack security group create arm-secu

openstack security group rule create --remote-ip 0.0.0.0/0 --dst-port 22 --protocol tcp --ingress arm-secu

openstack security group rule create --remote-ip 0.0.0.0/0 --dst-port 80 --protocol tcp --ingress arm-secu

openstack security group rule create --remote-ip 0.0.0.0/0 --protocol icmp --ingress arm-secu

openstack security group show arm-secu


##################################
# create init.sh
##################################
. admin-openrc

cat << EOF >init.sh
#cloud-config
password: stack
chpasswd: { expire: False }
ssh_pwauth: True
EOF












