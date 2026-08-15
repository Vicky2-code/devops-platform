output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "alb_dns_name" {
  description = "Public URL of the application load balancer"
  value       = module.compute.alb_dns
}

output "database_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.database.endpoint
  sensitive   = true
}

output "ecs_cluster" {
  description = "ECS cluster name"
  value       = "devflow-cluster"
}