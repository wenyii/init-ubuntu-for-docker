#! /bin/bash

name="init-ubuntu-for-docker"

# Preparatory work
direcotryName=`echo $PWD | awk -F "/" '{print $NF}'`
if [ "${direcotryName}" != $name ]
then
    echo -e "\n\033[1;31mPlease enter project ${name} first.\033[0;0m\n\a"
    exit 1
fi

echo -e "\n\033[1;32m ---------- INIT UBUNTU ----------\033[0;0m"
sudo kill -2 `pgrep docker`

echo -e "\n\033[1;34m ---------- install lsb-core ----------\033[0;0m\n"
sudo apt-get install -y lsb-core

# Get version of operation system
version=`sudo lsb_release -a | grep "Release" | awk -F " " '{print $2}'`

source ./library.sh

# Begin install docker-compose
echo -e "\n\033[1;34m ---------- install docker-composer-1.8.0 ----------\033[0;0m\n"
wget -c http://drycms.hk.ufileos.com/docker-compose-1.8.0 -O docker-compose
sudo mv docker-compose /usr/bin
sudo chmod a+x /usr/bin/docker-compose

# Check system version
if [ "`inarray 12.04 14.04 15.10 16.04 $version`" == "no" ]
then
    color 31 "Version $version is not recommend beyond them 12.04/14.04/15.01/16.04" "\n" "\n\a"
    
    echo -e "\033[1;34m ---------- install docker-1.11.2 ----------\033[0;0m\n"
    wget -c http://drycms.hk.ufileos.com/docker-1.11.2.tgz -O docker.tgz
    mkdir docker && tar -zxvf docker.tgz -C ./docker --strip-components 1
    sudo mv docker/* /usr/bin
    sudo rm -rf docker/
    sudo rm docker.tgz

    echo -e "\n\033[1;34m ---------- install aufs-tools ----------\033[0;0m\n"
    sudo apt-get install -y aufs-tools

    exit 2
fi

# Profile configure
function configure()
{
    echo -e "\n\033[1;34m ---------- init docker config ----------\033[0;0m\n"
    sudo sed -i '$a 117.144.208.130 git.9e.com hub.9e.com' /etc/hosts
    sudo sed -i '7a DOCKER_OPTS="-H unix:///var/run/docker.sock -H 0.0.0.0:5678 --insecure-registry hub.9e.com --storage-driver=aufs"' /etc/default/docker
    sudo sed -i '26c %sudo ALL=(ALL) PASSWD:ALL,NOPASSWD:/usr/bin/docker,/usr/bin/docker-compose' /etc/sudoers
}

# Post processed
function processed()
{
    # Move config
    if [ ! -d /etc/${name} ]
    then
        sudo mkdir /etc/${name}
    fi
    sudo cp -f ./server.ini /etc/${name}/server.ini

    # Move script (run-server)
    sudo cp -f ./run-server.sh /usr/bin/run-server
    sudo chmod a+x /usr/bin/run-server

    # Move library
    sudo cp -f ./library.sh /usr/local/lib/${name}-library.sh
}

# Begin install docker
echo -e "\n\033[1;34m ---------- update apt-get source ----------\033[0;0m\n"

if [ -f /etc/apt/sources.list.d/docker.list ]
then
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
fi

if [ "`inarray 14.04 15.10 16.04 $version`" == "yes" ]
then
    sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
    
    configure
    processed

    # Install sorfware
    source ./software.sh
else
    sudo apt-get install linux-image-generic-lts-trusty

    configure
    processed

    color 31 "The version of you operating system must reboot now (after 30s)." "\n" "\n\a"
    color 30 "After reboot you should run command: "
    color 34 "  $PWD/sorfware.sh" "\n" "\n"
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
