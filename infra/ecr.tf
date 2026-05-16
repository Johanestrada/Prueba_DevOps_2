## Ecr repositorio para las imagenes de docker 
## Repo del frontend
resource "aws_ecr_repository" "frontend" {
  name         = "${var.project_name}-frontend"
  force_delete = true

  tags = {
    Name = "${var.project_name}-frontend"
  }
}