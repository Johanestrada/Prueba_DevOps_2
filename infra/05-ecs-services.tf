# Referencia al rol existente LabRole para tareas ECS
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

resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"  # 2 vCPU
  memory                   = "10240"  # 10 GB
  execution_role_arn       = data.aws_iam_role.lab.arn

  container_definitions = jsonencode([
    {
      name      = "frontend-container",
      image     = aws_ecr_repository.frontend.repository_url, # Asumimos ECR de 01-network.tf
      cpu       = 2048,
      memory    = 10240,
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
  cpu                      = "2048"  # 2 vCPU
  memory                   = "10240" # 10 GB
  execution_role_arn       = data.aws_iam_role.lab.arn
    task_role_arn            = data.aws_iam_role.lab.arn

  container_definitions = jsonencode([
    {
      name      = "ventas-back-container",
      image     = aws_ecr_repository.ventas_back.repository_url,
      cpu       = 2048,
      memory    = 10240,
      essential = true,
      portMappings = [
        { containerPort = 8080, hostPort = 8080 }
      ],
      environment = [
        { name = "SPRING_DATASOURCE_URL", value = "jdbc:mysql://10.0.1.50:3306/ecommerce" },
        { name = "SPRING_DATASOURCE_USERNAME", value = "root" },
        { name = "SPRING_DATASOURCE_PASSWORD", value = "123456" }
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

  # Este servicio corre en subnets privadas
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
  cpu                      = "2048"
  memory                   = "10240"
  execution_role_arn       = data.aws_iam_role.lab.arn

  container_definitions = jsonencode([
    {
      name      = "despachos-back-container",
      image     = aws_ecr_repository.despachos_back.repository_url,
      cpu       = 2048,
      memory    = 10240,
      essential = true,
      portMappings = [
        { containerPort = 8080, hostPort = 8080 }
      ],
      environment = [
        { name = "SPRING_DATASOURCE_URL", value = "jdbc:mysql://10.0.1.50:3306/ecommerce" },
        { name = "SPRING_DATASOURCE_USERNAME", value = "root" },
        { name = "SPRING_DATASOURCE_PASSWORD", value = "123456" }
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
    subnets         = [aws_subnet.public_subnet.id]
    security_groups = [aws_security_group.backend_sg.id]
    assign_public_ip = true
  }
}