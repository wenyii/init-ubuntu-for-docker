#! /bin/bash

source ./library.sh

sudo apt-get install -y lsb-core

# Get version of operation system
version=`sudo lsb_release -a | grep "Release" | awk -F " " '{print $2}'`

# Check system version
if [ "`inarray 12.04 14.04 15.10 16.04 $version`" == "no" ]
then
    color 31 "Version $version is not recommend beyond them 12.04/14.04/15.01/16.04" "\n" "\n\a"
    
    cd /tmp

    sudo apt-get install -y openssh-server
    sudo apt-get install -y git

    wget -c http://drycms.hk.ufileos.com/docker-1.11.2.tgz -O docker.tgz
    mkdir docker && tar -zxvf docker.tgz -C ./docker --strip-components 1
    sudo mv docker/* /usr/bin
    sudo rm -rf docker/
    sudo rm docker.tgz

    wget -c http://drycms.hk.ufileos.com/docker-compose-1.8.0 -O docker-compose
    sudo mv docker-compose /usr/bin
    sudo chmod a+x /usr/bin/docker-compose

    sudo apt-get install -y aufs-tools

    exit 1
fi

# Begin install docker-compose
wget -c http://drycms.hk.ufileos.com/docker-compose-1.8.0 -O docker-compose
sudo mv docker-compose /usr/bin
sudo chmod a+x /usr/bin/docker-compose

# Profile configure
function configure()
{
    sudo sed -i '$a 117.144.208.130 git.9e.com hub.9e.com' /etc/hosts
    sudo sed -i '7a DOCKER_OPTS="-H unix:///var/run/docker.sock -H 0.0.0.0:5678 --insecure-registry hub.9e.com --storage-driver=aufs"' /etc/default/docker
    sudo sed -i '26c %sudo ALL=(ALL) PASSWD:ALL,NOPASSWD:/usr/bin/docker,/usr/bin/docker-compose' /etc/sudoers
}

# Post processed
function processed()
{
    name="init-ubuntu-for-docker"

    # Move config
    if [ ! -d /etc/${name} ]
    then
        sudo mkdir /etc/${name}
    fi
    sudo mv -f ./server.ini /etc/${name}/server.ini

    # Move script (run-server)
    sudo mv -f ./run-server.sh /usr/bin/run-server
    sudo chmod a+x /usr/bin/run-server

    # Move library
    sudo mv -f ./library.sh /usr/local/lib/${name}-library.sh

    # Remove self
    sudo rm -rf `pwd`
}

# Begin install docker
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

case $version in

    '12.04')
        deb="deb https://apt.dockerproject.org/repo ubuntu-precise main"
        ;;
    '14.04')
        deb='deb https://apt.dockerproject.org/repo ubuntu-trusty main'
        ;;
    '15.10')
        deb='deb https://apt.dockerproject.org/repo ubuntu-wily main'
        ;;
    '16.04')
        deb='deb https://apt.dockerproject.org/repo ubuntu-xenial main'
        ;;
esac

sudo touch /etc/apt/sources.list.d/docker.list
sudo chmod 777 /etc/apt/sources.list.d/docker.list
sudo echo $deb > /etc/apt/sources.list.d/docker.list

sudo apt-get update
sudo apt-get purge lxc-docker
sudo apt-cache policy docker-engine

if [ "`inarray 14.04 15.10 16.04 $version`" == "yes" ]
then
    sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
    
    configure
    processed

    # Install docker
    sudo apt-get install -y docker-engine
else
    sudo apt-get install linux-image-generic-lts-trusty

    configure
    processed

    color 31 "The version of you operating system must reboot now (after 30s)." "\n" "\n\a"
    color 30 "After reboot you should run command: "
    color 34 "  sudo apt-get install -y docker-engine" "\n" "\n"
    sleep 30
    sudo reboot
fi

# Upgrade docker
# sudo apt-get upgrade docker-engine

# Uninstallation
# sudo apt-get purge docker-engine
# sudo apt-get autoremove --purge docker-engine
# rm -rf /var/lib/docker

# -- eof --