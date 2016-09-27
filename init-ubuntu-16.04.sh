#! /bin/bash

cd /tmp

sudo apt-get install openssh-server
sudo apt-get install git

wget -c http://drycms.hk.ufileos.com/docker-1.11.2.tgz -O docker.tgz
mkdir docker && tar -zxvf docker.tgz -C ./docker --strip-components 1
sudo mv docker/* /usr/bin
sudo rm -rf docker/
sudo rm docker.tgz

wget -c http://drycms.hk.ufileos.com/docker-compose-1.8.0 -O docker-compose
sudo mv docker-compose /usr/bin
sudo chmod a+x /usr/bin/docker-compose

sudo apt-get install aufs-tools

ln -s ./run-server.sh /usr/bin/run-server
sudo chmod a+x /usr/bin/run-server
