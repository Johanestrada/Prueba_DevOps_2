data "aws_iam_role" "labrole" {
  name = "LabRole"
}

resource "aws_eks_cluster" "eks" {
  count    = var.enable_eks ? 1 : 0
  name     = var.eks_cluster_name
  role_arn = data.aws_iam_role.labrole.arn
  version  = "1.33"

  vpc_config {
    subnet_ids              = [aws_subnet.private_subnet.id, aws_subnet.private_subnet_b.id]
    endpoint_public_access  = true
    endpoint_private_access = false
    public_access_cidrs     = ["0.0.0.0/0"]
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
  }

  tags = {
    Project = var.project_name
  }
}

resource "aws_eks_node_group" "workers" {
  count           = var.enable_eks ? 1 : 0
  cluster_name    = aws_eks_cluster.eks[0].name
  node_group_name = "${var.project_name}-workers"
  node_role_arn   = data.aws_iam_role.labrole.arn
  subnet_ids      = [aws_subnet.private_subnet.id, aws_subnet.private_subnet_b.id]

  scaling_config {
    desired_size = var.eks_desired_capacity
    max_size     = var.eks_max_capacity
    min_size     = var.eks_min_capacity
  }

  instance_types = [var.eks_node_instance_type]
  ami_type = "AL2023_x86_64_STANDARD"
  capacity_type  = "ON_DEMAND"

  tags = {
    Project = var.project_name
  }
}
