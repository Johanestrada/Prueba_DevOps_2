# --- IAM Role para la ejecución de tareas ECS ---
# Usar un rol existente en la cuenta para evitar crear IAM Roles con permisos insuficientes.
data "aws_caller_identity" "current" {}

locals {
  ecs_task_execution_role_arn = var.ecs_task_execution_role_arn != "" ? var.ecs_task_execution_role_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.ecs_task_execution_role_name}"
}

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-ecs-cluster"
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"  # 0.25 vCPU
  memory                   = "512"  # 512 MB
  execution_role_arn       = local.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "frontend-container",
      image     = aws_ecr_repository.frontend.repository_url, # Asumimos ECR de 01-network.tf
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


# ===================================================================
# SERVICIO 2: VENTAS-BACKEND
# ===================================================================
resource "aws_ecs_task_definition" "ventas_back" {
  family                   = "ventas-back-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"  # 0.5 vCPU
  memory                   = "1024" # 1 GB
  execution_role_arn       = local.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "ventas-back-container",
      image     = aws_ecr_repository.ventas_back.repository_url,
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        { containerPort = 8080, hostPort = 8080 }
      ],
      environment = [
        { name = "SPRING_DATASOURCE_URL", value = "jdbc:mysql://${aws_instance.mysql.private_ip}:3306/ecommerce" },
        { name = "SPRING_DATASOURCE_USERNAME", value = "root" },
        { name = "SPRING_DATASOURCE_PASSWORD", value = "root" }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name,
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "ventas-back"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "ventas_back" {
  name            = "ventas-back-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ventas_back.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # Este servicio corre en subnets privadas por seguridad
  network_configuration {
    subnets         = [aws_subnet.private_subnet.id]
    security_groups = [aws_security_group.backend_sg.id]
    assign_public_ip = false
  }
}

# ===================================================================
# SERVICIO 3: DESPACHOS-BACKEND (¡No lo olvides!)
# ===================================================================
resource "aws_ecs_task_definition" "despachos_back" {
  family                   = "despachos-back-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = local.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "despachos-back-container",
      image     = aws_ecr_repository.despachos_back.repository_url,
      cpu       = 512,
      memory    = 1024,
      essential = true,
      portMappings = [
        { containerPort = 8080, hostPort = 8080 }
      ],
      environment = [
        { name = "SPRING_DATASOURCE_URL", value = "jdbc:mysql://${aws_instance.mysql.private_ip}:3306/ecommerce" },
        { name = "SPRING_DATASOURCE_USERNAME", value = "root" },
        { name = "SPRING_DATASOURCE_PASSWORD", value = "root" }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name,
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "despachos-back"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "despachos_back" {
  name            = "despachos-back-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.despachos_back.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private_subnet.id]
    security_groups = [aws_security_group.backend_sg.id]
    assign_public_ip = false
  }
}