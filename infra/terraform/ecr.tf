## Ecr repositorio para las imagenes de docker 

resource "aws_ecr_repository" "frontend" {
  name         = "${var.project_name}-frontend"
  force_delete = true

  tags = {
    Name = "${var.project_name}-frontend"
  }
}

resource "aws_ecr_repository" "ventas_back" {
  name         = "${var.project_name}-ventas-back"
  force_delete = true

  tags = {
    Name = "${var.project_name}-ventas-back"
  }
}

resource "aws_ecr_repository" "despachos_back" {
  name         = "${var.project_name}-despachos-back"
  force_delete = true

  tags = {
    Name = "${var.project_name}-despachos-back"
  }
}