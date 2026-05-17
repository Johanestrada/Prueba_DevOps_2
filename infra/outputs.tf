output "frontend_public_ip" {
  description = "IP pública del servicio frontend. Puede tardar en aparecer."
  value       = "Revisar la tarea de ECS 'frontend-service' en la consola de AWS para obtener la IP pública."
}

output "mysql_private_ip" {
  description = "Dirección IP privada de MySQL"
  value       = aws_instance.mysql.private_ip
}
output "mysql_instance_id" {
  description = "ID de la instancia MySQL"
  value       = aws_instance.mysql.id
}