variable "aws_region" {
  description = "Region AWS"
  type        = string
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "ecs_task_execution_role_name" {
  description = "Nombre del rol IAM de ejecución de tareas ECS existente"
  type        = string
  default     = "LabRole"
}

variable "ecs_task_execution_role_arn" {
  description = "ARN del rol IAM de ejecución de tareas ECS existente (opcional)"
  type        = string
  default     = ""
}

variable "key_pair_name" {
  description = "Key pair para acceso SSH"
  type        = string
}