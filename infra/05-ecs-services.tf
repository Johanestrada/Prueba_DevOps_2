# --- ECS cluster y rol existente para ejecución de tareas ---
# Usamos un rol IAM ya creado en la cuenta en lugar de crearlo desde Terraform.
data "aws_iam_role" "lab" {
  name = "LabRole"
}

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-ecs-cluster"
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7
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
#
resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"  # 0.25 vCPU
  memory                   = "512"  # 512 MB
  execution_role_arn       = data.aws_iam_role.lab.arn

  container_definitions = jsonencode([
    {
      name      = "frontend-container",
      image     = aws_ecr_repository.frontend.repository_url,
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        { containerPort = 80, hostPort = 80 }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name,
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "frontend"
        }
      }
    }
  ])
}


resource "aws_ecs_service" "frontend" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_subnet.id]
    security_groups = [aws_security_group.frontend_sg.id]
    assign_public_ip = true
  }
}