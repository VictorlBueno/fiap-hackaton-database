### Componentes Criados

- **RDS PostgreSQL 13.15**: Instância gerenciada pela AWS
- **Security Group**: Configurado para permitir acesso apenas do cluster EKS
- **Subnet Group**: Utilizando as subnets privadas da VPC
- **Parameter Group**: Configurações otimizadas para PostgreSQL
- **Secrets Manager**: Armazenamento seguro das credenciais
- **Backup Automático**: Configurado com retenção de 7 dias

### Características

- **Seguro**: Criptografia em repouso e em trânsito
- **Escalável**: Auto-scaling de storage até 100GB
- **Disponível**: Multi-AZ (quando necessário)
- **Monitorado**: Logs de conexões e queries lentas
- **Backup**: Automático com retenção configurável

## Pré-requisitos

- Terraform >= 1.0
- AWS CLI configurado
- VPC já criada (ver pasta `/vpc`)
- Bucket S3 para armazenar o state do Terraform

## Configuração

1. **Certifique-se que a VPC foi criada**:
   ```bash
   make deploy
   ```

2. **Configure as credenciais AWS** (se necessário):
   ```bash
   aws configure
   ```

## Deploy

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Destruir

```bash
cd terraform
terraform destroy
```

## Outputs

Após o deploy, você terá acesso aos seguintes outputs:

- `db_endpoint`: Endpoint do banco de dados
- `db_name`: Nome do banco de dados
- `db_username`: Usuário do banco
- `db_secret_arn`: ARN do secret com as credenciais
- `db_subnet_group_name`: Nome do subnet group
- `db_security_group_id`: ID do security group

## Conectividade

O banco está configurado para aceitar conexões apenas de:
- Security Group do cluster EKS
- Porta 5432 (PostgreSQL)
