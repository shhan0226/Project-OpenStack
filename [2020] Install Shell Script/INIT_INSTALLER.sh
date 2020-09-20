#! /bin/bash

##################################
IAMACCOUNT=$(whoami)
echo "${IAMACCOUNT}"

if [ "$IAMACCOUNT" = "root" ]
then
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
read -p "Input MARIADB_INSTALL? (y|n): " MARIADB_INSTALL
echo "$MARIADB_INSTALL"

if [ "${MARIADB_INSTALL}" = "y" ] 
then
	sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
	sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://ftp.harukasan.org/mariadb/repo/10.5/ubuntu bionic main'
	apt update -y
	apt dist-upgrade -y
	apt install mariadb-server -y
	apt install python3-pymysql -y
fi

##################################
echo "Install Simplejson ..."
read -p "Input SIMPLEJSON_INSTALL? (y|N): " SIMPLEJSON_INSTALL
#echo "$SIMPLEJSON_INSTALL"
sync

if [ "${SIMPLEJSON_INSTALL}" == "y" ] 
then
	pip install simplejson
	pip install --ignore-installed simplejson
fi

##################################
echo "Install C++ ..."
read -p "Input g++? (y|n): " G_INSTALL
sync

if [ "${G_INSTALL}" = "y" ]
then
	apt install g++ -y
	sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
	apt update -y
	apt dist-upgrade -y
	apt install g++-6 -y
	apt install g++-6-multilib -y
	sudo dpkg -l| grep g++ | awk '{print $2}'
	sudo update-alternatives --display g++
	sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-6 40
	sudo update-alternatives --config g++
fi

##################################
echo "INSTALL END!!"
