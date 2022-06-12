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

# This environment variable enables Windows access, which will also enable the VirtualBox and Hyper-V providers.
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
# Disable StrictHostKeyChecking for Ansible.
export ANSIBLE_HOST_KEY_CHECKING="False"
# Save windows ip address for later use.
export WINDOWS_HOST_IP=$(/bin/sh -c "ip route | grep default | grep -Po '\\d+.\\d+.\\d+.\\d+'")

########################################################################################################################
# VM and OS                                                                                                            #
########################################################################################################################

bash ./build-vm-and-os-v1.sh

if [ $? -ne 0 ]; then
    echo_red "Failed to build VM and OS."
    exit 1
fi

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
# MySQL Setup                                                                                                          #
########################################################################################################################

echo_module_start "MySQL Setup"
echo_cyan "Setting up MySQL...\n"

export VAGRANT_CWD="vagrant/mysql-host-v1"
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
./ansible/playbooks/mysql-v1.yml

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

export VAGRANT_CWD="vagrant/clickhouse-host-v1"
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
--inventory ${WINDOWS_HOST_IP}:22101, \
--user="vagrant" \
--private-key="${SSH_PRIVATE_KEY_FILE}" \
./ansible/playbooks/clickhouse-v1.yml

if [ "$?" -gt 0 ]; then
    echo_red "\nansible-playbook for ClickHouse failed!"
    exit 1
else
    echo_green "\nansible-playbook for ClickHouse succeeded!"
fi

########################################################################################################################
# Kafka Setup                                                                                                          #
########################################################################################################################

echo_module_start "Kafka Setup"
echo_cyan "Setting up Kafka...\n"
echo_cyan "Executing vagrant...\n"

export VAGRANT_CWD="vagrant/kafka-host-v1"
vagrant up

if [ "$?" -gt 0 ]; then
    echo_red "\nVagrant up for Kafka failed!"
    exit 1
else
    echo_green "\nVagrant up for Kafka succeeded!"
fi

# Grep generated SSH key from Vagrant.
export SSH_PRIVATE_KEY_FILE=$(
    /bin/sh -c "vagrant ssh-config | grep IdentityFile | grep -Po 'IdentityFile\\s\\S*'" | cut -d' ' -f2
)

echo_cyan "\nExecuting ansible-playbook...\n"
# Kafka PlayBook
ansible-playbook \
--inventory ${WINDOWS_HOST_IP}:22102, \
--user="vagrant" \
--private-key="${SSH_PRIVATE_KEY_FILE}" \
./ansible/playbooks/kafka-v1.yml

if [ "$?" -gt 0 ]; then
    echo_red "\nansible-playbook for Kafka failed!"
    exit 1
else
    echo_green "\nansible-playbook for Kafka succeeded!"
fi

########################################################################################################################
# Kafka MySQL Connector Configuration                                                                                  #
########################################################################################################################

echo_module_start "Kafka MySQL Connector Configuration"
echo_cyan "Configuring Kafka MySQL Connector...\n"

export VAGRANT_CWD="vagrant/kafka-host-v1"
export SSH_PRIVATE_KEY_FILE=$(
    /bin/sh -c "vagrant ssh-config | grep IdentityFile | grep -Po 'IdentityFile\\s\\S*'" | cut -d' ' -f2
)

echo_cyan "\nExecuting ansible-playbook...\n"
ansible-playbook \
--inventory ${WINDOWS_HOST_IP}:22102, \
--user="vagrant" \
--private-key="${SSH_PRIVATE_KEY_FILE}" \
--extra-vars "mysql_host=${WINDOWS_HOST_IP}" \
./ansible/playbooks/create-kafka-mysql-config-v1.yml

if [ "$?" -gt 0 ]; then
    echo_red "\nansible-playbook for Kafka MySQL Connector Configuration failed!"
    exit 1
else
    echo_green "\nansible-playbook for Kafka MySQL Connector Configuration succeeded!"
fi

########################################################################################################################
# ClickHouse Consumer Configuration                                                                                    #
########################################################################################################################

echo_module_start "ClickHouse Consumer Configuration"
echo_cyan "Configuring ClickHouse Consumer...\n"

export VAGRANT_CWD="vagrant/clickhouse-host-v1"
export SSH_PRIVATE_KEY_FILE=$(
    /bin/sh -c "vagrant ssh-config | grep IdentityFile | grep -Po 'IdentityFile\\s\\S*'" | cut -d' ' -f2
)

echo_cyan "\nExecuting ansible-playbook...\n"
ansible-playbook \
--inventory ${WINDOWS_HOST_IP}:22101, \
--user="vagrant" \
--private-key="${SSH_PRIVATE_KEY_FILE}" \
--extra-vars "kafka_host=${WINDOWS_HOST_IP}" \
./ansible/playbooks/clickhouse-consumer-v1.yml

if [ "$?" -gt 0 ]; then
    echo_red "\nansible-playbook for Kafka ClickHouse Consumer Configuration failed!"
    exit 1
else
    echo_green "\nansible-playbook for Kafka ClickHouse Consumer Configuration succeeded!"
fi