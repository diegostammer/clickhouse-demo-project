#!/bin/bash

# This script is used to run the project.

if [ ! "$BASH_VERSION" ] ; then
    echo "Please do not use sh to run this script ($0), just execute it directly" 1>&2
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

# Change it to your own Windows interface name.
export BRIDGE_NETWORK_IFACE_NAME="Intel(R) Ethernet Connection (2) I219-V"
# Change it to a valid and free IP in your network.
export MYSQL_PUBLIC_IP="192.168.15.100"
# Change it to a valid and free IP in your network.
export MYSQL_PRIVATE_IP="192.168.56.100"
# Change it to a valid and free IP in your network.
export CLICKHOUSE_PUBLIC_IP="192.168.15.101"
# Change it to a valid and free IP in your network.
export CLICKHOUSE_PRIVATE_IP="192.168.56.101"
# This environment variable enables Windows access, which will also enable the VirtualBox and Hyper-V providers.
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
# Disable StrictHostKeyChecking for Ansible.
export ANSIBLE_HOST_KEY_CHECKING="False"
# Save windows ip address for later use.
export WINDOWS_HOST_IP=$(/bin/sh -c "ip route | grep default | grep -Po '\\d+.\\d+.\\d+.\\d+'")

########################################################################################################################
# Sample Data                                                                                                          #
########################################################################################################################

echo_module_start "Sample Data"

if [ ! -f "./tmp/WHO-COVID-19-global-data.csv" ]; then
    echo_cyan "Downloading test data..."
    mkdir -p ./tmp
    wget -O ./tmp/WHO-COVID-19-global-data.csv https://covid19.who.int/WHO-COVID-19-global-data.csv

    if [ "$?" -gt 0 ]; then
        echo_red "Error downloading sample data!"
        exit 1
    else
        echo_green "Downloaded test data!"
    fi

else

    echo_green "Sample data already downloaded!"

fi

########################################################################################################################
# VM and OS                                                                                                            #
########################################################################################################################

./build-vm-and-os-v2.sh

if [ $? -ne 0 ]; then
    echo_red "Failed to build VM and OS."
    exit 1
fi

########################################################################################################################
# MySQL Setup                                                                                                          #
########################################################################################################################

echo_module_start "MySQL Setup"
echo_cyan "Setting up MySQL...\n"

export VAGRANT_CWD="vagrant/mysql-host-v2"
# Grep generated SSH key from Vagrant.
export SSH_PRIVATE_KEY_FILE=$(
    /bin/sh -c "vagrant ssh-config | grep IdentityFile | grep -Po 'IdentityFile\\s\\S*'" | cut -d' ' -f2
)

echo_cyan "\nExecuting ansible-playbook...\n"
# MySQL PlayBook
ansible-playbook \
--inventory ${MYSQL_PUBLIC_IP}, \
--user="vagrant" \
--private-key="${SSH_PRIVATE_KEY_FILE}" \
./ansible/playbooks/mysql-v2.yml

if [ "$?" -gt 0 ]; then
    echo_red "\nansible-playbook for MySQL failed!"
    exit 1
else
    echo_green "\nansible-playbook for MySQL succeeded!"
fi

########################################################################################################################
# ClickHouse Setup                                                                                                     #
########################################################################################################################

echo_module_start "ClickHouse Setup"
echo_cyan "Setting up ClickHouse...\n"
echo_cyan "Executing vagrant...\n"

export VAGRANT_CWD="vagrant/clickhouse-host-v2"
vagrant up

if [ "$?" -gt 0 ]; then
    echo_red "\nVagrant up for ClickHouse failed!"
    exit 1
else
    echo_green "\nVagrant up for ClickHouse succeeded!"
fi

# Grep generated SSH key from Vagrant.
export SSH_PRIVATE_KEY_FILE=$(
    /bin/sh -c "vagrant ssh-config | grep IdentityFile | grep -Po 'IdentityFile\\s\\S*'" | cut -d' ' -f2
)

echo_cyan "\nExecuting ansible-playbook...\n"
# ClickHouse PlayBook
ansible-playbook \
--inventory ${CLICKHOUSE_PUBLIC_IP}, \
--user="vagrant" \
--private-key="${SSH_PRIVATE_KEY_FILE}" \
./ansible/playbooks/clickhouse-v2.yml

if [ "$?" -gt 0 ]; then
    echo_red "\nansible-playbook for ClickHouse failed!"
    exit 1
else
    echo_green "\nansible-playbook for ClickHouse succeeded!"
fi

########################################################################################################################
# ClickHouse MySQL Replication                                                                                         #
########################################################################################################################

echo_module_start "ClickHouse MySQL Replication"
echo_cyan "Configuring ClickHouse MySQL Replication...\n"

export VAGRANT_CWD="vagrant/clickhouse-host-v2"
export SSH_PRIVATE_KEY_FILE=$(
    /bin/sh -c "vagrant ssh-config | grep IdentityFile | grep -Po 'IdentityFile\\s\\S*'" | cut -d' ' -f2
)

echo_cyan "\nExecuting ansible-playbook...\n"
ansible-playbook \
--inventory ${CLICKHOUSE_PUBLIC_IP}, \
--user="vagrant" \
--private-key="${SSH_PRIVATE_KEY_FILE}" \
--extra-vars "mysql_host=${MYSQL_PUBLIC_IP}" \
./ansible/playbooks/clickhouse-mysql-replication-v2.yml

if [ "$?" -gt 0 ]; then
    echo_red "\nansible-playbook for ClickHouse MySQL Replication failed!"
    exit 1
else
    echo_green "\nansible-playbook for ClickHouse MySQL Replication succeeded!"
fi

########################################################################################################################
# Compare MySQL To ClickHouse                                                                                          #
########################################################################################################################

echo_module_start "Compare MySQL To ClickHouse"
echo_cyan "Running Compare MySQL To ClickHouse...\n"

export VAGRANT_CWD="vagrant/clickhouse-host-v2"
export SSH_PRIVATE_KEY_FILE=$(
    /bin/sh -c "vagrant ssh-config | grep IdentityFile | grep -Po 'IdentityFile\\s\\S*'" | cut -d' ' -f2
)

echo_cyan "\nExecuting ansible-playbook...\n"
ansible-playbook \
--inventory ${CLICKHOUSE_PUBLIC_IP}, \
--user="vagrant" \
--private-key="${SSH_PRIVATE_KEY_FILE}" \
--extra-vars "mysql_host=${MYSQL_PUBLIC_IP}" \
--extra-vars "mysql_user=covid19" \
--extra-vars "mysql_pass=covid19" \
--extra-vars "mysql_db=covid19" \
--extra-vars "mysql_port=covid19" \
--extra-vars "mysql_table=covid19_cases" \
--extra-vars "clickhouse_database=covid19" \
--extra-vars "clickhouse_table=covid19_cases" \
./ansible/playbooks/compare-mysql-clickhouse-v2.yml

if [ "$?" -gt 0 ]; then
    echo_red "\nansible-playbook for Compare MySQL To ClickHouse failed!"
    exit 1
else
    echo_green "\nansible-playbook for Compare MySQL To ClickHouse succeeded!"
fi

echo_green "\n\nAll done!\n"