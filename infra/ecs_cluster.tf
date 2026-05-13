# --- ECS Cluster ---

resource "aws_ecs_cluster" "main" {
  name = "ecommerce-cluster"
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/ecommerce-app"
  retention_in_days = 7 # Guardar logs por 7 días
}

resource "aws_lb" "main" {
  name               = "ecommerce-alb"
  internal           = false
  load_balancer_type = "application"
  # Asumimos que estos recursos se crean en 01-network.tf y 02-security.tf
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "ecommerce-alb"
  }
}


resource "aws_lb_target_group" "frontend" {
  name        = "ecommerce-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id # Asumimos que la VPC se crea en 01-network.tf
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}