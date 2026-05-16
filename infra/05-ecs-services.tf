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

resource "aws_lb" "internal" {
  name               = "${var.project_name}-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_b.id]

  tags = {
    Name = "${var.project_name}-internal-alb"
  }
}

resource "aws_lb_target_group" "ventas_back" {
  name        = "${var.project_name}-ventas-back-tg"
  target_type = "ip"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/actuator/health"
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = {
    Name = "${var.project_name}-ventas-back-tg"
  }
}

resource "aws_lb_listener" "ventas_back" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ventas_back.arn
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
#
resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256" # 0.25 vCPU
  memory                   = "512" # 512 MB
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
      environment = [
        {
          name  = "VENTAS_BACK_HOST"
          value = aws_lb.internal.dns_name
        }
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
    subnets          = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_b.id]
    security_groups  = [aws_security_group.frontend_sg.id]
    assign_public_ip = true
  }
}

# ------------------------
# ECS TASK + SERVICE for ventas-back
# ------------------------
resource "aws_ecs_task_definition" "ventas_back" {
  family                   = "ventas-back-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.lab.arn

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

  network_configuration {
    subnets          = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_b.id]
    security_groups  = [aws_security_group.backend_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ventas_back.arn
    container_name   = "ventas-back-container"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.ventas_back]
}

# ------------------------
# ECS TASK + SERVICE for despachos-back
# ------------------------
resource "aws_ecs_task_definition" "despachos_back" {
  family                   = "despachos-back-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.lab.arn

  container_definitions = jsonencode([
    {
      name      = "despachos-back-container",
      image     = aws_ecr_repository.despachos_back.repository_url,
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        { containerPort = 8080, hostPort = 8080 }
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
    subnets          = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_b.id]
    security_groups  = [aws_security_group.backend_sg.id]
    assign_public_ip = true
  }
}