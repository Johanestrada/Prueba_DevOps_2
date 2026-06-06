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
