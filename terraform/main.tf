data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "fiap-hack-terraform-state"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Component   = "database"
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "fiap-hack-rds-"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr]
    description = "PostgreSQL from VPC"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }
  
  tags = merge(local.tags, {
    Name = "fiap-hack-rds-sg"
  })
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  
  tags = local.tags
}

resource "aws_db_parameter_group" "main" {
  family = "postgres13"
  name   = "${var.project_name}-postgres13"
  
  parameter {
    name  = "log_connections"
    value = "1"
  }
  
  parameter {
    name  = "log_disconnections"
    value = "1"
  }
  
  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }
  
  tags = local.tags
}

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-postgres"
  
  allocated_storage      = var.db_allocated_storage
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.db_password.result
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name
  publicly_accessible    = false
  
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  
  deletion_protection = false
  skip_final_snapshot    = true
  
  storage_encrypted = true
  
  tags = merge(local.tags, {
    Name = "${var.project_name}-postgres"
  })
}

resource "random_password" "db_password" {
  length  = 16
  special = false
  upper   = true
  lower   = true
  numeric = true
}

data "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.project_name}/db-credentials"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = data.aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = aws_db_instance.main.username
    password = random_password.db_password.result
    host     = aws_db_instance.main.endpoint
    port     = 5432
    database = aws_db_instance.main.db_name
    url      = "postgresql://${aws_db_instance.main.username}:${random_password.db_password.result}@${aws_db_instance.main.endpoint}/${aws_db_instance.main.db_name}"
  })
}

output "db_endpoint" {
  description = "Endpoint do banco de dados"
  value       = aws_db_instance.main.endpoint
}

output "db_name" {
  description = "Nome do banco de dados"
  value       = aws_db_instance.main.db_name
}

output "db_username" {
  description = "Usuário do banco de dados"
  value       = aws_db_instance.main.username
}

output "db_password" {
  description = "Senha do banco de dados"
  value       = random_password.db_password.result
  sensitive   = true
}

output "db_secret_arn" {
  description = "ARN do secret com as credenciais"
  value       = data.aws_secretsmanager_secret.db_credentials.arn
}

output "db_subnet_group_name" {
  description = "Nome do subnet group do banco"
  value       = aws_db_subnet_group.main.name
}

output "db_security_group_id" {
  description = "ID do security group do banco"
  value       = aws_security_group.rds.id
} 