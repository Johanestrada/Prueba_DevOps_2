output "frontend_public_ip" {
  description = "Dirección IP pública del frontend"
  value       = aws_instance.frontend.public_ip
}

output "backend_private_ip" {
  description = "Dirección IP privada del backend"
  value       = aws_instance.backend.private_ip
}

output "mysql_private_ip" {
  description = "Dirección IP privada de MySQL"
  value       = aws_instance.mysql.private_ip
}

output "frontend_instance_id" {
  description = "ID de la instancia frontend"
  value       = aws_instance.frontend.id
}

output "backend_instance_id" {
  description = "ID de la instancia backend"
  value       = aws_instance.backend.id
}

output "mysql_instance_id" {
  description = "ID de la instancia MySQL"
  value       = aws_instance.mysql.id
}