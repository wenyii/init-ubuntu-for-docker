#! /bin/bash

# Mysql client
sudo apt-get install mysql-client-core-5.7

# Openssh
sudo apt-get install -y openssh-server

# Init ssh
ssh-keygen -t rsa -P ''
sudo touch ~/.ssh/authorized_keys
sudo chmod 600 ?_

# Git
sudo apt-get install -y git