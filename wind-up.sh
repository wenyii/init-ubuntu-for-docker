#! /bin/bash

sudo sed -i '$a 117.144.208.130 git.9e.com hub.9e.com' /etc/hosts
sudo sed -i '7a DOCKER_OPTS="-H unix:///var/run/docker.sock -H 0.0.0.0:5678 --insecure-registry hub.9e.com --storage-driver=aufs"' /etc/default/docker
sudo sed -i '26c %sudo ALL=(ALL) PASSWD:ALL,NOPASSWD:/usr/bin/docker,/usr/bin/docker-compose' /etc/sudoers

sudo apt-get install -y docker-engine
sudo service docker start

# -- eof --