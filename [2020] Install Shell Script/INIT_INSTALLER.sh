#! /bin/bash

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
echo "APT update..."
apt update -y
apt dist-upgrade -y

##################################
echo "Python & pip SET ..."
apt install python3-pip -y
update-alternatives --install /usr/bin/python python /usr/bin/python3.6 1
update-alternatives --config python
sudo -H pip3 install --upgrade pip

##################################
echo "Install git ..."
apt install git -y
git config --global user.name shhan0226
git config --global user.email shhan0226@gmail.com

##################################
echo "Install Mariadb ..."
read -p "[Mariadb] Would you like to install it? <y|n>: " MARIADB_INSTALL
echo "$MARIADB_INSTALL"

if [ "${MARIADB_INSTALL}" = "y" ]; then
	sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
	sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://ftp.harukasan.org/mariadb/repo/10.5/ubuntu bionic main'
	apt update -y
	apt dist-upgrade -y
	apt install mariadb-server -y
	apt install python3-pymysql -y
fi

##################################
echo "Install Simplejson ..."
read -p "[Simplejson] Would you like to install it? <y|n>: " SIMPLEJSON_INSTALL
#echo "$SIMPLEJSON_INSTALL"
sync

if [ "${SIMPLEJSON_INSTALL}" = "y" ]; then
	pip install simplejson
	sync
	pip install --ignore-installed simplejson
fi

##################################
echo "Install C++ ..."
read -p "[G++] Would you like to install it? <y|n>: " G_INSTALL
sync

if [ "${G_INSTALL}" = "y" ]; then
	apt install g++ -y
	sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
	apt update -y
	apt dist-upgrade -y
	apt install -y g++-6
	apt install -y g++-6-multilib
	sudo dpkg -l| grep g++ | awk '{print $2}'
	sudo update-alternatives --display g++
	sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-6 40
	sudo update-alternatives --config g++
fi

##################################
echo "Install Django ..."
read -p "[Django] Would you like to install it? <y|n>: " DJANOG_INSTALL
sync

if [ "${DJANOG_INSTALL}" = "y" ]; then
	pip install Django
	pip install Django --upgrade
	python -m django --version
fi

##################################
echo "Install crudini ..."
read -p "[crudini] Would you like to install it? <y|n>: " CRUDINI_INSTALL
sync

if [ "${CRUDINI_INSTALL}" = "y" ]; then
	apt install -y python3-iniparse
	git clone https://github.com/pixelb/crudini.git
	mv crudini /usr/bin/crudinid 
	ln -s /usr/bin/crudinid/crudini /usr/bin/crudini
fi

##################################
echo "Install Openstack Client ..."
read -p "[Openstack-client] Would you like to install it? <y|n>: " OPENSTACKCLIENT_INSTALL
sync

if [ "${OPENSTACKCLIENT_INSTALL}" = "y" ]; then
	sudo add-apt-repository cloud-archive:stein -y
	apt update -y
        apt dist-upgrade -y
	apt install python3-openstackclient -y
	openstack --version
fi

##################################
echo "IP Setting ..."
ifconfig
read -p "Input IP: " SET_IP
echo "$SET_IP	controller" >> /etc/hosts
echo "$SET_IP	compute" >> /etc/hosts


##################################
echo "Openstack Mariadb Set ..."
read -p "[Openstack-Mariadb] Would you like to setting it? <y|n>: " OPENSTACK_DB_SET
sync

if [ "${OPENSTACK_DB_SET}" = "y" ]; then

        touch /etc/mysql/mariadb.conf.d/99-openstack.cnf
        crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld bind-address $SET_IP
        crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld default-storage-engine innodb
        crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld innodb_file_per_table on
        crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld max_connections 4096
        crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld collation-server utf8_general_ci
        crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld character-set-server utf8
	
	service mysql restart
	echo -e "\ny\ny\nstack\nstack\ny\ny\ny\ny" | mysql_secure_installation
fi

##################################
echo "Install Message queue ..."
read -p "[rabbitmq-server] Would you like to install it? <y|n>: " RABBIT_INSTALL
sync

if [ "${RABBIT_INSTALL}" = "y" ]; then
	apt install rabbitmq-server -y
	rabbitmqctl add_user openstack stack
	sync
	rabbitmqctl set_permissions openstack ".*" ".*" ".*"
	sync

fi

##################################
echo "Install Memcached ..."
read -p "[Memcached] Would you like to install it? <y|n>: " MAMCACHED_INSTALL
sync

if [ "${MAMCACHED_INSTALL}" = "y" ]; then
        apt install memcached -y
        apt install python3-memcache -y
        sed -i s/127.0.0.1/${SET_IP}/ /etc/memcached.conf
        service memcached restart
fi

##################################
echo "Install ETCD ..."
read -p "[Etcd] Would you like to install it? <y|n>: " ETCD_INSTALL
sync

if [ "${ETCD_INSTALL}" = "y" ]; then
	echo "ETCD_NAME=\"controller\"" >> /etc/default/etcd
	echo "ETCD_DATA_DIR=\"/var/lib/etcd\"" >> /etc/default/etcd
	echo "ETCD_INITIAL_CLUSTER_STATE=\"new\"" >> /etc/default/etcd
	echo "ETCD_INITIAL_CLUSTER_TOKEN=\"etcd-cluster-01\"" >> /etc/default/etcd
	echo "ETCD_INITIAL_CLUSTER=\"controller=http://${SET_IP}:2380\"" >> /etc/default/etcd
	echo "ETCD_INITIAL_ADVERTISE_PEER_URLS=\"http://${SET_IP}:2380\"" >> /etc/default/etcd
	echo "ETCD_ADVERTISE_CLIENT_URLS=\"http://${SET_IP}:2379\"" >> /etc/default/etcd
	echo "ETCD_LISTEN_PEER_URLS=\"http://0.0.0.0:2380\"" >> /etc/default/etcd
	echo "ETCD_LISTEN_CLIENT_URLS=\"http://${SET_IP}:2379\"" >> /etc/default/etcd

	systemctl enable etcd
	systemctl restart etcd
fi

##################################
apt update -y
apt dist-upgrade -y
apt autoremove -y

echo "----------------------------------------------------------"
echo "THE END !!!"
echo " "
echo ">"
echo "If you want to connect the compute nodes, you need to install NTP."
