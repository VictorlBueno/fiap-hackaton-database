.PHONY: help init plan apply destroy output clean

help: ## Mostra esta ajuda
	@echo "Comandos disponíveis:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

init: ## Inicializa o Terraform
	cd terraform && terraform init

plan: ## Executa o plan do Terraform
	cd terraform && terraform plan

apply: ## Aplica as mudanças do Terraform
	cd terraform && terraform apply -auto-approve

destroy: ## Destroi a infraestrutura
	cd terraform && terraform destroy -auto-approve

output: ## Mostra os outputs do Terraform
	cd terraform && terraform output

validate: ## Valida os arquivos do Terraform
	cd terraform && terraform validate

fmt: ## Formata os arquivos do Terraform
	cd terraform && terraform fmt -recursive

clean: ## Remove arquivos temporários
	cd terraform && rm -rf .terraform .terraform.lock.hcl

deploy: init plan apply output ## Deploy completo do banco de dados

get-credentials: ## Obtém as credenciais do banco do Secrets Manager
	aws secretsmanager get-secret-value --secret-id fiap-hack/db-credentials --query SecretString --output text | jq -r '.url'

test-connection: ## Testa a conexão com o banco (requer psql)
	$(eval DB_URL := $(shell aws secretsmanager get-secret-value --secret-id fiap-hack/db-credentials --query SecretString --output text | jq -r '.url'))
	psql "$(DB_URL)" -c "SELECT version();" 