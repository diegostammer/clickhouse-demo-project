# CLICKHOUSE DEMO PROJECT

In this project I demonstrate my abilities to handle different tools together with ClickHouse database.

## CHALLANGES

### MAIN CHALLANGES

1. Install and load sample data to one of the popular open-source OLTP databases (MySQL, Postgresql, MongoDB)
2. Install and configure the Clickhouse database on another host or the same host.
3. Migrate data loaded to OLTP database (MySQL/PostgreSQL, MongoDB) to Clickhouse without causing downtime to the source database.
4. Query data from source and destination to compare.

### BONUS CHALLANGES

1. Make the process repeatable
2. Make data flow streaming online
3. Add monitoring to source/destination

## TOOLS AND RESOURCES

This is the list of tools and resources I have used in this project:

* Vagrant
* Ansible
* ClickHouse database
* MySQL database
* Kafka
* Zabbix
* Grafana

## PROJECT STORY

When I started this project I didn't have any **ClickHouse** nor **Kafka** experience.

The first thing I tried to do was to build a replication from **MySQL** to **ClickHouse** using **Kafka**, and I partially succeded.
I was able to build the replication and store the replcated data into **ClickHouse** as JSON, although as time was running out I decided to not convert this JSON to the final table (and I don't know if this is a secure aproach).
So, I started using the **MaterializedMySQL** engine from **ClickHouse** and it worked like a charm.

So, here we have two versions to run it:

* **build-it-v1.sh**: create the replication using **Kafka** and storing the replicated data as JASON.
* **build-it-v2.sh**: create the replication using **MaterializedMySQL** engine from **ClickHouse**.

## REQUIREMENTS

> ⚠️ This project was tested with a Windows desktop, running commands from WSL 2 (Ubuntu 20.04.2 LTS).

Execute requirements:

```bash
chmod +x requirements.sh
./requirements.sh
```

## RUNNING IT

Execute using the desired version:

MySQL -> Kafka -> ClickHouse

```bash
./build-it-v1.sh
```

MySQL -> ClickHouse (MaterializedMySQL)

```bash
./build-it-v2.sh
```

## DESTROY IT

Destroy using the desired version:

MySQL -> Kafka -> ClickHouse

```bash
./destroy-it-v1.sh
```

MySQL -> ClickHouse (MaterializedMySQL)

```bash
./destroy-it-v2.sh
```

## WHAT'S NEXT

* Add Monitoring To V2
* Add Full Comparison To V2
* Change V1 to work as desired replicating to a equaly table in **ClickHouse** (Not storing as JSON).
* Add Monitoring To V1
* Add Full Comparison To V1
* Build V3 using **Docker** and **Kubernetes**.bu

## REFERENCES

### VAGRANT

[https://www.vagrantup.com/docs/other/wsl](https://www.vagrantup.com/docs/other/wsl)

[https://blog.thenets.org/how-to-run-vagrant-on-wsl-2/](https://blog.thenets.org/how-to-run-vagrant-on-wsl-2/)

[https://www.vagrantup.com/docs/networking/public_network](https://www.vagrantup.com/docs/networking/public_network)

### ANSIBLE

[https://www.cyberciti.biz/faq/ansible-apt-update-all-packages-on-ubuntu-debian-linux/](https://www.cyberciti.biz/faq/ansible-apt-update-all-packages-on-ubuntu-debian-linux/)

[https://www.middlewareinventory.com/blog/ansible-copy-file-or-directory-local-to-remote/](https://www.middlewareinventory.com/blog/ansible-copy-file-or-directory-local-to-remote/)

[https://www.ansiblepilot.com/articles/pass-variables-to-ansible-playbook-in-command-line-ansible-extra-variables/#:~:text=The%20easiest%20way%20to%20pass,pre%2Dexistent%20automation%20or%20script.](https://www.ansiblepilot.com/articles/pass-variables-to-ansible-playbook-in-command-line-ansible-extra-variables/#:~:text=The%20easiest%20way%20to%20pass,pre%2Dexistent%20automation%20or%20script.)

[https://docs.ansible.com/ansible/latest/collections/community/mysql/mysql_query_module.html](https://docs.ansible.com/ansible/latest/collections/community/mysql/mysql_query_module.html)

[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html)

[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html)

[https://docs.ansible.com/ansible/latest/collections/community/mysql/mysql_db_module.html](https://docs.ansible.com/ansible/latest/collections/community/mysql/mysql_db_module.html)

[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_key_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_key_module.html)

[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_repository_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_repository_module.html)

[https://docs.ansible.com/ansible/latest/collections/community/general/xml_module.html](https://docs.ansible.com/ansible/latest/collections/community/general/xml_module.html)

[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html)

[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html)

[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/group_module.html#ansible-collections-ansible-builtin-group-module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/group_module.html#ansible-collections-ansible-builtin-group-module)

[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/get_url_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/get_url_module.html)

[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html)

[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/unarchive_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/unarchive_module.html)

[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fail_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fail_module.html)

### CLICKHOUSE

[https://clickhouse.com/docs/en/quick-start/](https://clickhouse.com/docs/en/quick-start/)

[https://clickhouse.com/docs/en/getting-started/install/](https://clickhouse.com/docs/en/getting-started/install/)

[https://clickhouse.com/docs/en/operations/server-configuration-parameters/settings/](https://clickhouse.com/docs/en/operations/server-configuration-parameters/settings/)

[https://clickhouse.com/docs/en/engines/database-engines/materialized-mysql](https://clickhouse.com/docs/en/engines/database-engines/materialized-mysql)

[https://clickhouse.com/docs/en/interfaces/cli/](https://clickhouse.com/docs/en/interfaces/cli/)

### KAFKA

[https://www.digitalocean.com/community/tutorials/how-to-install-apache-kafka-on-ubuntu-20-04](https://www.digitalocean.com/community/tutorials/how-to-install-apache-kafka-on-ubuntu-20-04)

[https://blog.clairvoyantsoft.com/mysql-cdc-with-apache-kafka-and-debezium-3d45c00762e4](https://blog.clairvoyantsoft.com/mysql-cdc-with-apache-kafka-and-debezium-3d45c00762e4)

[https://blog.pythian.com/replicating-mysql-to-snowflake-with-kafka-and-debezium-part-one-data-extraction/](https://blog.pythian.com/replicating-mysql-to-snowflake-with-kafka-and-debezium-part-one-data-extraction/)

[https://debezium.io/documentation/reference/stable/connectors/mysql.html](https://debezium.io/documentation/reference/stable/connectors/mysql.html)
