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
#apt install wget -y
#wget http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2
#wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
#wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-arm64.img
#sync


##################################
# create project
##################################
. admin-openrc
sync
echo "openstack project list..."
openstack project list


#################################
echo "Time Checker Start!!!!!!!!!"
StartTime=$(date +%s)


##################################
# create External Net
##################################
. admin-openrc
sync
echo "external net..."
openstack network create --external --provider-network-type flat --provider-physical-network provider external


##################################
# create Subnet External Net
##################################
. admin-openrc
ifconfig
sync
#read -p "External Subnet range: (ex 10.0.10.0/24) " SUBNET_RANGE
#sync

#read -p "External Start IP: (ex 10.0.10.100) " START_IP
#sync

#read -p "External End IP: (ex 10.0.10.200) " END_IP
#sync

#read -p "External Gateway IP: " GATEWAY_IP
#sync

echo "external sub net..."
#openstack subnet create --subnet-range ${SUBNET_RANGE} --no-dhcp --gateway ${GATEWAY_IP} --network external --allocation-pool start=${START_IP},end=${END_IP} external-subnet
openstack subnet create --subnet-range 192.168.0.0/24 --no-dhcp --gateway 192.168.0.1 --network external --allocation-pool start=192.168.0.100,end=192.168.0.150 external-subnet

sync


##################################
# create Internal Net
##################################
. demo-openrc
sync
echo "internal net..."
openstack network create internal

sync


##################################
# create Subnet Internal Net
##################################
. demo-openrc
sync

#read -p "Internal Subnet range: (ex 172.10.0.0/24) " SUBNET_RANGE2
#sync

echo "insternal sub net..."
#openstack subnet create --subnet-range ${SUBNET_RANGE2} --dhcp --network internal --dns-nameserver 8.8.8.8 internal-subnet
openstack subnet create --subnet-range 172.10.0.0/24 --dhcp --network internal --dns-nameserver 8.8.8.8 internal-subnet
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


##################################
# create flavor(Instance TEMP)
##################################
. admin-openrc

echo "create flavor..."
openstack flavor create --vcpus 4 --ram 4096 --disk 30 arm-flavor

echo "flavor list..."
openstack flavor list


##################################
# create img
##################################
. admin-openrc

echo "image create..."
openstack image create "ubuntu1804" --file ./bionic-server-cloudimg-arm64.img --disk-format qcow2 --public

echo "image show..."
openstack image show ubuntu1804
sync


##################################
# create Instance
##################################
. demo-openrc
#openstack server list
#read -p "Input VM Name: " VM_NAME
#sync
#echo "${VM_NAME}"
#sync

echo "server create..."
. demo-openrc
#openstack server create --image ubuntu1804 --flavor arm-flavor --key-name arm-key --network internal --user-data init.sh --security-group arm-secu ${VM_NAME}
openstack server create --image ubuntu1804 --flavor arm-flavor --key-name arm-key --network internal --user-data init.sh --security-group arm-secu vm-ubuntu

echo "server list..."
openstack server list


#################################
echo "Time Checker END!!!!!!!!!"
EndTime=$(date +%s)
echo "It takes $(($EndTime - $StartTime)) seconds to complete this task."


##################################
# Add Floating IP
##################################
. demo-openrc

echo "floating ip create..."
openstack floating ip create external

read -p "Input floating IP: " F_IP
sync
echo "vm-ubuntu ${F_IP}"

echo "server add floating ip..."
openstack server add floating ip vm-ubuntu ${F_IP}

chmod 400 arm-key.pem
echo "================================="
echo "ssh -i arm-key.pem ubuntu@${F_IP}"
echo "================================="
echo "END..."
