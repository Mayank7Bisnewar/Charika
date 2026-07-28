output "ecr_repository_url" {
  description = "ECR repository URL for the backend image"
  value       = aws_ecr_repository.backend.repository_url
}

output "database_endpoint" {
  description = "PostgreSQL endpoint for the RDS instance"
  value       = aws_db_instance.charika.address
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.charika.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.charika.name
}

output "load_balancer_dns_name" {
  description = "Public DNS name for the application load balancer"
  value       = aws_lb.charika.dns_name
}
