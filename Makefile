# ============================================
# Diploma Project Makefile
# ============================================

TERRAFORM_DIR = terraform
ANSIBLE_DIR = ansible
SSH_KEY = ~/.ssh/id_ed25519
BASTION_USER = ubuntu

.PHONY: deploy tf-init tf-plan tf-apply tf-destroy tf-output
.PHONY: generate-inventory ansible-ping ansible-all galaxy-install
.PHONY: ssh-bastion ssh-web-a ssh-web-b ssh-zabbix ssh-elastic ssh-kibana
.PHONY: info test status help

deploy: tf-apply generate-inventory galaxy-install ansible-all
	@echo ""
	@echo "========================================"
	@echo "   РАЗВЁРТЫВАНИЕ ЗАВЕРШЕНО!"
	@echo "========================================"
	@echo ""
	@make info

tf-init:
	cd $(TERRAFORM_DIR) && terraform init

tf-plan:
	cd $(TERRAFORM_DIR) && terraform plan

tf-apply:
	cd $(TERRAFORM_DIR) && terraform apply -parallelism=1

tf-destroy:
	@read -p "yes для удаления: " CONFIRM; \
	if [ "$$CONFIRM" = "yes" ]; then \
		cd $(TERRAFORM_DIR) && terraform destroy -auto-approve; \
	fi

tf-output:
	cd $(TERRAFORM_DIR) && terraform output

generate-inventory:
	./generate_inventory.sh

galaxy-install:
	ansible-galaxy collection install -r $(ANSIBLE_DIR)/requirements.yml
	pip install --break-system-packages zabbix-api

ansible-ping: generate-inventory
	ansible -i $(ANSIBLE_DIR)/inventory.ini all -m ping
ansible-all: generate-inventory
	ANSIBLE_ROLES_PATH=$(ANSIBLE_DIR)/roles ansible-playbook -i $(ANSIBLE_DIR)/inventory.ini $(ANSIBLE_DIR)/playbooks/site.yml

ssh-bastion:
	@BASTION_IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw bastion_public_ip); \
	ssh -i $(SSH_KEY) $(BASTION_USER)@$$BASTION_IP

ssh-web-a:
	@BASTION_IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw bastion_public_ip); \
	ssh -i $(SSH_KEY) -J $(BASTION_USER)@$$BASTION_IP $(BASTION_USER)@web-a.ru-central1.internal

ssh-web-b:
	@BASTION_IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw bastion_public_ip); \
	ssh -i $(SSH_KEY) -J $(BASTION_USER)@$$BASTION_IP $(BASTION_USER)@web-b.ru-central1.internal

ssh-zabbix:
	@BASTION_IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw bastion_public_ip); \
	ssh -i $(SSH_KEY) -J $(BASTION_USER)@$$BASTION_IP $(BASTION_USER)@zabbix.ru-central1.internal

ssh-elastic:
	@BASTION_IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw bastion_public_ip); \
	ssh -i $(SSH_KEY) -J $(BASTION_USER)@$$BASTION_IP $(BASTION_USER)@elastic.ru-central1.internal

ssh-kibana:
	@BASTION_IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw bastion_public_ip); \
	ssh -i $(SSH_KEY) -J $(BASTION_USER)@$$BASTION_IP $(BASTION_USER)@kibana.ru-central1.internal

info:
	@echo "=== Информация ==="
	@echo -n "Bastion: "; cd $(TERRAFORM_DIR) && terraform output -raw bastion_public_ip 2>/dev/null || echo "N/A"
	@echo -n "Zabbix:  "; cd $(TERRAFORM_DIR) && terraform output -raw zabbix_public_ip 2>/dev/null || echo "N/A"
	@echo -n "Kibana:  "; cd $(TERRAFORM_DIR) && terraform output -raw kibana_public_ip 2>/dev/null || echo "N/A"
	@echo -n "ALB:     "; cd $(TERRAFORM_DIR) && terraform output -json alb_public_ip 2>/dev/null | grep -oP '"address"\s*:\s*"\K[^"]+' || echo "N/A"
	@echo ""
	@echo "Ссылки:"
	@echo -n "Сайт:    http://"; cd $(TERRAFORM_DIR) && terraform output -json alb_public_ip 2>/dev/null | grep -oP '"address"\s*:\s*"\K[^"]+' || echo "N/A"
	@echo -n "Zabbix:  http://"; cd $(TERRAFORM_DIR) && terraform output -raw zabbix_public_ip 2>/dev/null || echo "N/A"; echo ":8080"
	@echo -n "Kibana:  http://"; cd $(TERRAFORM_DIR) && terraform output -raw kibana_public_ip 2>/dev/null || echo "N/A"; echo ":5601"

test:
	@ALB_IP=$$(cd $(TERRAFORM_DIR) && terraform output -json alb_public_ip 2>/dev/null | grep -oP '"address"\s*:\s*"\K[^"]+'); \
	curl -s http://$$ALB_IP/ | head -20

status: info test

help:
	@echo "=== Команды ==="
	@echo "  make deploy          - Полное развёртывание"
	@echo "  make galaxy-install  - Установить Ansible-коллекции (Zabbix API)"
	@echo "  make ansible-ping    - Проверить связь"
	@echo "  make ansible-all     - Настроить серверы"
	@echo "  make ssh-bastion     - SSH на бастион"
	@echo "  make ssh-web-a       - SSH на web-a (через бастион)"
	@echo "  make ssh-web-b       - SSH на web-b (через бастион)"
	@echo "  make ssh-zabbix      - SSH на zabbix (через бастион)"
	@echo "  make ssh-elastic     - SSH на elastic (через бастион)"
	@echo "  make ssh-kibana      - SSH на kibana (через бастион)"
	@echo "  make info            - IP и ссылки"
	@echo "  make test            - Проверить сайт"

.DEFAULT_GOAL := help