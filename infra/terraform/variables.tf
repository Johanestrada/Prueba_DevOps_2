variable "aws_region" {
  description = "Region AWS"
  type        = string
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

### Variables ECS comentadas porque la infraestructura se migrará a EKS
### Estas variables eran específicas para ejecución de tareas ECS/Fargate.
# variable "ecs_task_execution_role_name" {
#   description = "Nombre del rol IAM de ejecución de tareas ECS existente"
#   type        = string
#   default     = "LabRole"
# }
#
# variable "ecs_task_execution_role_arn" {
#   description = "ARN del rol IAM de ejecución de tareas ECS existente (opcional)"
#   type        = string
#   default     = ""
# }

variable "key_pair_name" {
  description = "Key pair para acceso SSH; dejar vacío si no se usa"
  type        = string
  default     = ""
}

variable "enable_eks" {
  description = "Habilitar provisionamiento de EKS (true/false)"
  type        = bool
  default     = true
}

variable "eks_cluster_name" {
  description = "Nombre del cluster EKS"
  type        = string
  default     = "app-eks-cluster"
}

variable "eks_node_instance_type" {
  description = "Tipo de instancia para los nodos EKS"
  type        = string
  default     = "t3.medium"
}

variable "eks_desired_capacity" {
  description = "Cantidad deseada de nodos en el grupo"
  type        = number
  default     = 2
}

variable "eks_min_capacity" {
  description = "Capacidad mínima de nodos"
  type        = number
  default     = 1
}

variable "eks_max_capacity" {
  description = "Capacidad máxima de nodos"
  type        = number
  default     = 3
}

variable "mysql_database" {
  description = "Nombre de la base de datos MySQL"
  type        = string
  default     = "ecommerce"
}

variable "mysql_root_password" {
  description = "Password root para MySQL"
  type        = string
  sensitive   = true
}
