output "project_name" {
  description = "Terraform project name"
  value       = var.project_name
}

output "mysql_private_ip" {
  description = "Dirección IP privada de MySQL"
  value       = aws_instance.mysql.private_ip
}

output "mysql_instance_id" {
  description = "ID de la instancia MySQL"
  value       = aws_instance.mysql.id
}

output "ecr_frontend_repository_url" {
  description = "ECR repository URL for frontend"
  value       = aws_ecr_repository.frontend.repository_url
}

output "ecr_ventas_repository_url" {
  description = "ECR repository URL for ventas backend"
  value       = aws_ecr_repository.ventas_back.repository_url
}

output "ecr_despachos_repository_url" {
  description = "ECR repository URL for despachos backend"
  value       = aws_ecr_repository.despachos_back.repository_url
}
