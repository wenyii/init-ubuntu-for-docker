#! /bin/bash

source ./library.sh

# Get version of operation system
version=`sudo lsb_release -a | grep "Release" | awk -F " " '{print $2}'`

# Check system version
if [ "`inarray 12.04 14.04 15.10 16.04 $version`" == "no" ]
then
    color 31 "Version $version is not recommend beyond them 12.04/14.04/15.01/16.04" "\n" "\n\a"
    source ./others-system.sh
    exit 1
fi

# Begin install
if [ ! -f /usr/bin/docker -a ! -f /usr/bin/docker-compose ]
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

    if [ "`inarray 14.04 15.10 16.04 $version`" == "yes" ]
    then
        sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
        source ./wind-up.sh
    else
        sudo apt-get install linux-image-generic-lts-trusty

        color 31 "The version of you operating system must reboot now (after 20s)." "\n" "\n\a"
        color 30 "After reboot you should run command: "
        color 34 "  ./wind-up.sh" "\n" "\n"
        sleep 20
        sudo reboot
    fi
fi

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

# Upgrade docker
# sudo apt-get upgrade docker-engine

# Uninstallation
# sudo apt-get purge docker-engine
# sudo apt-get autoremove --purge docker-engine
# rm -rf /var/lib/docker

# -- eof --