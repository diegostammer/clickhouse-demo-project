#!/bin/bash

# This script is used to run the project.

if [ ! "$BASH_VERSION" ] ; then
    echo "Please do not use sh to run this script ($0), just execute it directly" 1>&2
    exit 1
fi

read -p "Are you sure? [Y/y] " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

########################################################################################################################
# Colors Setup                                                                                                         #
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
# Delete Sample Data                                                                                                   #
########################################################################################################################

echo_module_start "Delete Sample Data"

if [ -f "./tmp/WHO-COVID-19-global-data.csv" ]; then
    
    rm -rf ./tmp/WHO-COVID-19-global-data.csv

    if [ "$?" -gt 0 ]; then
        echo_red "Error deleting sample data!"
        exit 1
    else
        echo_green "Deleted test data!"
    fi

else

    echo_green "Sample data already deleted!"

fi

########################################################################################################################
# Destroy MySQL Host                                                                                                   #
########################################################################################################################

echo_module_start "Destroy MySQL Host"
echo_cyan "Destroying MySQL Host...\n"
echo_cyan "Executing vagrant...\n"

export VAGRANT_CWD="vagrant/mysql-host-v2"
vagrant destroy --force

if [ "$?" -gt 0 ]; then
    echo_red "\nVagrant destroy for MySQL Host failed!"
    exit 1
else 
    echo_green "\nVagrant destroy for MySQL Host succeeded!"
fi

########################################################################################################################
# Destroy ClickHouse Host                                                                                              #
########################################################################################################################

echo_module_start "Destroy ClickHouse Host"
echo_cyan "Destroying ClickHouse Host...\n"
echo_cyan "Executing vagrant...\n"

export VAGRANT_CWD="vagrant/clickhouse-host-v2"
vagrant destroy --force

if [ "$?" -gt 0 ]; then
    echo_red "\nVagrant destroy for ClickHouse Host failed!"
    exit 1
else 
    echo_green "\nVagrant destroy for ClickHouse Host succeeded!"
fi

echo_green "\n\nAll done!\n"