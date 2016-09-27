#!/bin/bash

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo touch /etc/apt/sources.list.d/docker.list
sudo chmod 777 /etc/apt/sources.list.d/docker.list
sudo echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' > /etc/apt/sources.list.d/docker.list

sudo apt-get update
sudo apt-get purge lxc-docker
sudo apt-cache policy docker-engine
sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
sudo apt-get install -y docker-engine

sudo sed -i '$a 117.144.208.130 git.9e.com hub.9e.com' /etc/hosts
sudo sed -i '7a DOCKER_OPTS="-H unix:///var/run/docker.sock -H 0.0.0.0:5678 --insecure-registry hub.9e.com --storage-driver=aufs"' /etc/default/docker
sudo sed -i '26c %sudo ALL=(ALL) PASSWD:ALL,NOPASSWD:/usr/bin/docker,/usr/bin/docker-compose' /etc/sudoers
sudo service docker restart
sudo docker --version
