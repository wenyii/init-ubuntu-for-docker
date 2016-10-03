#! /bin/bash

# Mysql client
sudo apt-get install mysql-client-core-5.7

# Openssh
sudo apt-get install -y openssh-server

# Init ssh
if [ ! -d ~/.ssh ]
then
    ssh-keygen -t rsa -P ''
fi

if [ ! -f ~/.ssh/authorized_keys ]
then
    sudo touch ~/.ssh/authorized_keys
    sudo chmod 600 ?_
fi

# Git
sudo apt-get install -y git

# Vim config
cat > ~/.vimrc << EOF
syntax on
set number
set tabstop=4
set expandtab
set softtabstop=4
set shiftwidth=4
EOF
