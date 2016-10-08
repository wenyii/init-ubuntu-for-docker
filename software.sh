#! /bin/bash

sudo apt-get install -y docker-engine

echo -e "\n\033[1;32m ---------- BEGIN INSTALL SOFTWARE ----------\033[0;0m"

# Mysql client
echo -e "\n\033[1;34m ---------- install mysql-client-core-5.7 ----------\033[0;0m\n"
sudo apt-get install mysql-client-core-5.7

# Openssh
echo -e "\n\033[1;34m  ---------- install openssh-server ----------\033[0;0m\n"
sudo apt-get install -y openssh-server

# Init ssh
if [ ! -d ~/.ssh ]
then
    echo -e "\n\033[1;34m  ---------- init ssh ----------\033[0;0m\n"
    ssh-keygen -t rsa -P ''
fi

if [ ! -f ~/.ssh/authorized_keys ]
then
    echo -e "\n\033[1;34m ---------- create ssh auth file ----------\033[0;0m\n"
    sudo touch ~/.ssh/authorized_keys
    sudo chmod 600 ~/.ssh/authorized_keys
fi

# Git
echo -e "\n\033[1;34m  ---------- install git ----------\033[0;0m\n"
sudo apt-get install -y git

# Vim
echo -e "\n\033[1;34m  ---------- install vim ----------\033[0;0m\n"
sudo apt-get install -y vim

# Vim config
echo -e "\n\033[1;34m  ---------- create vim config ----------\033[0;0m\n"
cat > ~/.vimrc << EOF
syntax on
set number
set tabstop=4
set expandtab
set softtabstop=4
set shiftwidth=4
EOF

# Composer for docker
if [ `sudo docker images -a | grep 'composer/composer' | wc -l` == 0 ]
then
    echo -e "\n\033[1;34m  ---------- pull cocker images composer ----------\033[0;0m\n"
    sudo docker pull composer/composer:1.1-php5
fi

if [ `cat ~/.bashrc | grep 'alias composer' | wc -l` == 0 ]
then
    echo -e "\n\033[1;34m  ---------- build alias composer ----------\033[0;0m\n"
    echo "alias composer='sudo docker run --rm -v \$(pwd):/app composer/composer:1.1-php5'" >> ~/.bashrc
    
    unset composer
    source ~/.bashrc
fi

# if [ "`echo $PWD | awk -F "/" '{print $NF}'`" == "init-ubuntu-for-docker" ]
# then
#     sudo rm -rf `pwd`
# fi

# -- eof --
