#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/terraform"
BASTION_IP=$(terraform output -raw bastion_public_ip)
ZABBIX_IP=$(terraform output -raw zabbix_public_ip)
KIBANA_IP=$(terraform output -raw kibana_public_ip)
cd "$SCRIPT_DIR"
echo "Bastion: $BASTION_IP"
echo "Zabbix: $ZABBIX_IP"
echo "Kibana: $KIBANA_IP"
mkdir -p ansible
cat > ansible/inventory.ini << ENDOFFILE
[all:vars]
ansible_user = ubuntu
ansible_ssh_private_key_file = ~/.ssh/id_ed25519
ansible_ssh_common_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

[bastion]
bastion.ru-central1.internal ansible_host=${BASTION_IP}

[webservers]
web-a.ru-central1.internal
web-b.ru-central1.internal

[webservers:vars]
ansible_ssh_common_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -W %h:%p -q ubuntu@${BASTION_IP} -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no"

[zabbix_server]
zabbix.ru-central1.internal

[zabbix_server:vars]
ansible_ssh_common_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -W %h:%p -q ubuntu@${BASTION_IP} -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no"

[elasticsearch]
elastic.ru-central1.internal

[elasticsearch:vars]
ansible_ssh_common_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -W %h:%p -q ubuntu@${BASTION_IP} -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no"

[kibana]
kibana.ru-central1.internal

[kibana:vars]
ansible_ssh_common_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -W %h:%p -q ubuntu@${BASTION_IP} -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no"
ENDOFFILE
echo "Inventory создан!"
cat ansible/inventory.ini