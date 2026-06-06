output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = var.enable_eks ? module.eks[0].cluster_name : ""
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = var.enable_eks ? module.eks[0].cluster_arn : ""
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = var.enable_eks ? module.eks[0].cluster_endpoint : ""
}

output "eks_cluster_certificate_authority_data" {
  description = "CA data for the cluster"
  value       = var.enable_eks ? module.eks[0].cluster_certificate_authority_data : ""
}

output "eks_oidc_provider_arn" {
  description = "OIDC provider ARN used for IRSA"
  value       = var.enable_eks ? module.eks[0].oidc_provider_arn : ""
}

output "eks_node_security_group_id" {
  description = "Security group for the EKS node group"
  value       = var.enable_eks ? module.eks[0].node_security_group_id : ""
}

output "eks_cluster_security_group_id" {
  description = "Security group for the EKS cluster"
  value       = var.enable_eks ? module.eks[0].cluster_security_group_id : ""
}
