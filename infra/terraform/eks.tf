module "eks" {
  source = "./modules/eks"

  count = var.enable_eks ? 1 : 0

  cluster_name    = var.eks_cluster_name
  cluster_version = "1.33"
  create_iam_role = false
  iam_role_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"

  cluster_endpoint_public_access           = true
  cluster_endpoint_private_access          = false
  enable_cluster_creator_admin_permissions = false
  enable_irsa                              = false
  cluster_encryption_config                = {}
  create_kms_key                           = false
  attach_cluster_encryption_policy         = false

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = aws_vpc.main.id
  subnet_ids               = [aws_subnet.private_subnet.id, aws_subnet.private_subnet_b.id]
  control_plane_subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.private_subnet_b.id]

  access_entries = {
    lab_admin = {
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/voclabs"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  eks_managed_node_group_defaults = {
    ami_type        = "AL2023_x86_64_STANDARD"
    instance_types  = [var.eks_node_instance_type]
    create_iam_role = false
    iam_role_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  }

  eks_managed_node_groups = {
    default = {
      min_size     = var.eks_min_capacity
      max_size     = var.eks_max_capacity
      desired_size = var.eks_desired_capacity
      key_name     = var.key_pair_name

      tags = {
        Name = "${var.project_name}-eks-node"
      }
    }
  }

  tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}
