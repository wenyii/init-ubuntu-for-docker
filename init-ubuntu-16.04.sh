#! /bin/bash

pwd=`pwd`
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

sudo rm -rf /usr/bin/run-server
sudo ln -s ${pwd}/run-server.sh /usr/bin/run-server

version=`cat /etc/issue | grep "14.04"`
if [ -n "${version}" ]
then
    sudo chmod a+x ./patch-ubuntu-14.04.sh
    source ./patch-ubuntu-14.04.sh
fi