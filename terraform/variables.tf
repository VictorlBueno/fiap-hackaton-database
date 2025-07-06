variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de deploy"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "fiap-hack"
}

variable "db_instance_class" {
  description = "Classe da instância do RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Storage alocado em GB"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Storage máximo alocado em GB"
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "fiaphack"
}

variable "db_username" {
  description = "Usuário do banco de dados"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Versão do PostgreSQL"
  type        = string
  default     = "13.15"
}

variable "backup_retention_period" {
  description = "Período de retenção de backup em dias"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Janela de backup"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Janela de manutenção"
  type        = string
  default     = "sun:04:00-sun:05:00"
} 