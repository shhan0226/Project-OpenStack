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
# apt를 업데이트 합니다.
##################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "APT update..."
apt update -y
apt dist-upgrade -y

##################################
# python을 설치하세요.
##################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "Python & pip SET ..."
apt install python3-pip -y
update-alternatives --install /usr/bin/python python /usr/bin/python3.6 1
update-alternatives --config python
sudo -H pip3 install --upgrade pip

##################################
# git을 설치하세요.
##################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "Install git ..."
apt install git -y
apt install wget -y

##################################
# grub-efi 설치 합니다.
##################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "Install grub ..."
sudo apt-get purge grub\*
apt install grub-common -y
apt install grub2-common -y
# sudo apt-get install grub-efi
sudo apt-get autoremove
sudo update-grub
sync

##################################
# Mariadb를 설치하세요.
##################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
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
# /etc/hosts설정 합니다.
##################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "IP Setting ..."
ifconfig
read -p "Input Contorller IP: (ex.192.168.0.2) " SET_IP
read -p "Input Compute IP: (ex.192.168.0.3) " SET_IP2
echo "$SET_IP controller" >> /etc/hosts
echo "$SET_IP2 compute" >> /etc/hosts

##################################
# NTP 설치하세요.
##################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "INSTALL NTP ..."
read -p "[NTP] Is this a Controller Node? <y|n>: " CONTROLLER_NODE
sync

if [ "${CONTROLLER_NODE}" = "y" ]; then
	apt install chrony -y
	echo "server $SET_IP iburst" >> /etc/chrony/chrony.conf
	read -p "please input the allow IP (ex 192.168.0.0/24): " SET_IP_ALLOW
	echo "$SET_IP_ALLOW"
	echo "allow $SET_IP_ALLOW" >> /etc/chrony/chrony.conf
	service chrony restart
	chronyc sources

else
	read -p "[NTP] Is this a Compute Node? <y|n>: " COMPUTE_NODE
	sync
	if [ "${COMPUTE_NODE}" = "y" ]; then
        	apt install chrony -y
		sed -i 's/pool/#pool/' /etc/chrony/chrony.conf
        	echo "server controller iburst" >> /etc/chrony/chrony.conf
        	service chrony restart
        	chronyc sources
	fi
	
fi

##################################
# NTP error?
##################################
read -p "[NTP] NTP ERROR? <y|n>: " NTP_ERROR
sync

if [ "${NTP_ERROR}" = "y" ]; then
        killall apt apt-get -y
	rm /var/lib/apt/lists/lock
	rm /var/cache/apt/archives/lock
	rm /var/lib/dpkg/lock*
	dpkg --configure -a 
	apt update -y
	cd ~
fi





##################################
#
##################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
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
#
##################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "Install crudini ..."
read -p "[crudini] Would you like to install it? <y|n>: " CRUDINI_INSTALL
sync

if [ "${CRUDINI_INSTALL}" = "y" ]; then
	apt install -y python3-iniparse
	git clone https://github.com/pixelb/crudini.git
	mv crudini /usr/bin/crudinid 
	ln -s /usr/bin/crudinid/crudini /usr/bin/crudini
	sync
	cd ~
fi

##################################
#
##################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
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
#
##################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
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
#
##################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
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
#
##################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
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
#
##################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "Install ETCD ..."
read -p "[Etcd] Would you like to install it? <y|n>: " ETCD_INSTALL
sync

if [ "${ETCD_INSTALL}" = "y" ]; then
	groupadd --system etcd
	useradd --home-dir "/var/lib/etcd" --system --shell /bin/false -g etcd etcd
	mkdir -p /etc/etcd
	chown etcd:etcd /etc/etcd
	mkdir -p /var/lib/etcd
	chown etcd:etcd /var/lib/etcd
	
	wget https://github.com/etcd-io/etcd/releases/download/v3.4.1/etcd-v3.4.1-linux-arm64.tar.gz
	tar -xvf etcd-v3.4.1-linux-arm64.tar.gz
	sudo cp etcd-v3.4.1-linux-arm64/etcd* /usr/bin/
	
	#crudini --set
	#crudini --set
	
	
	
	# export ETCD_UNSUPPORTED_ARCH=arm64
	# RELEASE="3.3.13"
	# wget https://github.com/etcd-io/etcd/releases/download/v${RELEASE}/etcd-v${RELEASE}-linux-arm64.tar.gz
	# tar xvf etcd-v${RELEASE}-linux-arm64.tar.gz
	# cd etcd-v${RELEASE}-linux-arm64
	# mv etcd etcdctl /usr/local/bin
	# etcd --version
	# mkdir -p /var/lib/etcd/
	# mkdir /etc/etcd
	# sudo groupadd --system etcd
	# sudo useradd -s /sbin/nologin --system -g etcd etcd
	# sudo chown -R etcd:etcd /var/lib/etcd/
	# sync
	# cd ~
	# systemctl daemon-reload
	# systemctl start etcd.service
	# sync
	# echo "ETCD_NAME=\"controller\"" >> /etc/default/etcd
	# echo "ETCD_DATA_DIR=\"/var/lib/etcd\"" >> /etc/default/etcd
	# echo "ETCD_INITIAL_CLUSTER_STATE=\"new\"" >> /etc/default/etcd
	# echo "ETCD_INITIAL_CLUSTER_TOKEN=\"etcd-cluster-01\"" >> /etc/default/etcd
	# echo "ETCD_INITIAL_CLUSTER=\"controller=http://${SET_IP}:2380\"" >> /etc/default/etcd
	# echo "ETCD_INITIAL_ADVERTISE_PEER_URLS=\"http://${SET_IP}:2380\"" >> /etc/default/etcd
	# echo "ETCD_ADVERTISE_CLIENT_URLS=\"http://${SET_IP}:2379\"" >> /etc/default/etcd
	# echo "ETCD_LISTEN_PEER_URLS=\"http://0.0.0.0:2380\"" >> /etc/default/etcd
	# echo "ETCD_LISTEN_CLIENT_URLS=\"http://${SET_IP}:2379\"" >> /etc/default/etcd
        # systemctl enable etcd
	# systemctl restart etcd
fi

##################################
#
##################################
apt update -y
apt dist-upgrade -y
apt autoremove -y

echo "=========================================================="
echo "Openstack installation END !!!"
openstack --version
echo "=========================================================="
echo " "
python --version
pip --version
echo "----------------------------------------------------------"
service --status-all|grep +
echo ">"
echo "----------------------------------------------------------"
echo "THE END !!!"
