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

sync
. demo-openrc

# openstack server remove floating ip INSTANCE_NAME_OR_ID FLOATING_IP_ADDRESS
openstack server remove floating ip

# openstack floating ip delete FLOATING_IP_ADDRESS
openstack floating ip delete

# openstack server delete INSTANCE_NAME_OR_ID
openstack server delete


echo "server list..."
openstack server list



. admin-openrc

# openstack image delete name
openstack image delete ubuntu1804


# openstack flavor delete name
openstack flavor delete arm-flavor



#
rm -rf init.sh
sync



. demo-openrc

# openstack security group delete name
openstack security group delete arm-secu


# openstack keypair delte name
openstack keypair delete arm-key


# openstack router unset name
openstack router unset arm-router

# openstack router remove subnet name(router) name(subnet)
openstack router remove subnet arm-router internal-subnet

# openstack router delete name
openstack router delete arm-router

# openstack network delete name
openstack network delete internal

. admin-openrc
openstack network delete external
