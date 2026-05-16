## Ecr repositorio para las imagenes de docker 
## primero la del backend 
resource "aws_ecr_repository" "backend" {
  name         = "${var.project_name}-backend"
  force_delete = true

  tags = {
    Name = "${var.project_name}-backend"
  }
}
## ahora la que es para el frontend
resource "aws_ecr_repository" "frontend" {
  name         = "${var.project_name}-frontend"
  force_delete = true

  tags = {
    Name = "${var.project_name}-frontend"
  }
}