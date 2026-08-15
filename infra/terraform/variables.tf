variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "devflow"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "devflow"
  sensitive   = true
}

variable "db_password" {
  description = "Database password (set via tfvars / secret)"
  type        = string
  sensitive   = true
}

variable "backend_image" {
  description = "Backend container image"
  type        = string
  default     = "ghcr.io/vicky2-code/devops-cloud-automation-platform-backend:latest"
}

variable "frontend_image" {
  description = "Frontend container image"
  type        = string
  default     = "ghcr.io/vicky2-code/devops-cloud-automation-platform-frontend:latest"
}