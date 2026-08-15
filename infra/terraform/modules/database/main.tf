# Database module: RDS Postgres in private subnets.
variable "environment" {}
variable "vpc_id" {}
variable "private_subnets" {}
variable "vpc_cidr" {}
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "db_instance_class" {}

output "endpoint"   { value = aws_db_instance.db.endpoint }
output "security_group_id" { value = aws_security_group.db.id }

resource "aws_security_group" "db" {
  name   = "devflow-db-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # only traffic from inside the VPC
  }

  tags = { Name = "devflow-db-sg", Environment = var.environment }
}

resource "aws_db_subnet_group" "db" {
  name       = "devflow-db-subnets"
  subnet_ids = var.private_subnets
  tags       = { Name = "devflow-db-subnets", Environment = var.environment }
}

resource "aws_db_instance" "db" {
  identifier             = "devflow-db"
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = var.db_instance_class
  allocated_storage       = 20
  storage_encrypted       = true
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = var.environment != "prod"
  auto_minor_version_upgrade = true

  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db.id]
  multi_az               = var.environment == "prod"

  tags = { Name = "devflow-db", Environment = var.environment }
}