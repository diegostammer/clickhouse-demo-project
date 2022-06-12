#!/bin/bash

# Install Vagrant
sudo apt install vagrant -y

# Install virtualbox_WSL2 plugin on WSL 2 to enable Windows network access from WSL
vagrant plugin install virtualbox_WSL2

# Install latest version of ansible on WSL 2:
sudo apt remove ansible
sudo apt --purge autoremove
sudo apt update
sudo apt install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt update
sudo apt install ansible -y

# Install ansible galaxy collections
ansible-galaxy collection install community.general
ansible-galaxy collection install community.mysql

# Add Execution Permission
chmod +x build-it-v1.sh
chmod +x build-it-v2.sh
chmod +x build-vm-and-os-v1.sh
chmod +x build-vm-and-os-v2.sh
chmod +x destroy-it-v1.sh
chmod +x destroy-it-v2.sh

# Create required directory
mkdir -p tmp