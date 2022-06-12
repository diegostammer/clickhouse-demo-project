#!/bin/bash

# This script is used to create VMs and configure OS.

if [ ! "$BASH_VERSION" ] ; then
    echo "Please do not use sh to run this script ($0), just execute it directly" 1>&2
    exit 1
fi

########################################################################################################################
# Colors Setup                                                                                                         #                                                                                                          #
########################################################################################################################

GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

########################################################################################################################
# Functions                                                                                                            #
########################################################################################################################

echo_green() {
    echo -e "${GREEN}$1${NC}"
}

echo_cyan() {
    echo -e "${CYAN}$1${NC}"
}

echo_red() {
    echo -e "${RED}$1${NC}"
}

echo_module_start() {

    local divisor=$(python -c 'print("#"*80)')

    echo_cyan "\n\n${divisor}"
    echo_cyan "# $1"
    echo_cyan "${divisor}\n"

}

########################################################################################################################
# Required Environment Variables                                                                                       #
########################################################################################################################

# This environment variable enables Windows access, which will also enable the VirtualBox and Hyper-V providers.
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
# Disable StrictHostKeyChecking for Ansible.
export ANSIBLE_HOST_KEY_CHECKING="False"
# Save windows ip address for later use.
export WINDOWS_HOST_IP=$(/bin/sh -c "ip route | grep default | grep -Po '\\d+.\\d+.\\d+.\\d+'")

########################################################################################################################
# MySQL VM and OS                                                                                                      #
########################################################################################################################

echo_module_start "MySQL VM and OS "
echo_cyan "Setting up MySQL VM and OS...\n"
echo_cyan "Executing vagrant...\n"

export VAGRANT_CWD="vagrant/mysql-host-v1"
vagrant up

if [ "$?" -gt 0 ]; then
    echo_red "\nVagrant up for MySQL failed!"
    exit 1
else 
    echo_green "\nVagrant up for MySQL succeeded!"
fi

# Grep generated SSH key from Vagrant.
export SSH_PRIVATE_KEY_FILE=$(
    /bin/sh -c "vagrant ssh-config | grep IdentityFile | grep -Po 'IdentityFile\\s\\S*'" | cut -d' ' -f2
)

echo_cyan "\nExecuting ansible-playbook...\n"
# MySQL PlayBook
ansible-playbook \
--inventory ${WINDOWS_HOST_IP}:22100, \
--user="vagrant" \
--private-key="${SSH_PRIVATE_KEY_FILE}" \
./ansible/playbooks/mysql-vm-and-os-v1.yml

if [ "$?" -gt 0 ]; then
    echo_red "\nansible-playbook for MySQL VM and OS failed!"
    exit 1
else
    echo_green "\nansible-playbook for MySQL VM and OS succeeded!"
fi