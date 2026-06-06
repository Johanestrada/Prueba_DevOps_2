output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = var.enable_eks ? aws_eks_cluster.eks[0].name : ""
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = var.enable_eks ? aws_eks_cluster.eks[0].arn : ""
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = var.enable_eks ? aws_eks_cluster.eks[0].endpoint : ""
}

output "eks_cluster_certificate_authority_data" {
  description = "CA data for the cluster"
  value       = var.enable_eks ? aws_eks_cluster.eks[0].certificate_authority[0].data : ""
}

output "eks_cluster_security_group_id" {
  description = "Security group for the EKS cluster"
  value       = var.enable_eks ? aws_eks_cluster.eks[0].vpc_config[0].cluster_security_group_id : ""
}
