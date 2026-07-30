############################ EKS ############################
module "eks" {
  source                       = "./modules/eks/node_group"
  project                      = local.project
  tags                         = local.tags
  eks_name                     = "lab"
  eks_version                  = "1.31"
  eks_subnet                   = local.network.private_subnet_ids
  eks_vpc                      = local.network.vpc_id
  endpoint_private_access      = true
  endpoint_public_access       = true
  endpoint_public_access_cidrs = ["0.0.0.0/0"] # Your office ip or office cidr
  # Security Group Ingress
  eks_sg_ingress = {
    ingress_rules = {
      rule1 = {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
        description = "Test dynamic rules"
      }
    }
  }

  # Ensure VPC infrastructure is fully created before EKS
  depends_on = [
    module.vpc
  ]

  # Node Groups
  node_groups = {
    node1 = {
      subnet_ids     = local.network.private_subnet_ids
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND" #ON_DEMAND or SPOT
      disk_size      = 10
      ami_type       = "AL2023_x86_64_STANDARD"
      disk_type      = "gp3"
      ingress_rules = {
        ssh = {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow SSH from VPC for node1"
        }
      }
    }

    # Spot instance 
    node2 = {
      subnet_ids     = [local.network.private_subnet_ids[0]]
      min_size       = 2
      max_size       = 10
      desired_size   = 4
      instance_types = ["t3.medium", "t3.small", "t3.large"]
      capacity_type  = "SPOT" #ON_DEMAND or SPOT
      disk_size      = 20
      disk_type      = "gp3"
      ingress_rules = {
        ssh = {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow SSH from VPC for node2"
        }
      }
    }
    node3 = {
      subnet_ids     = [local.network.private_subnet_ids[1]]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND" #ON_DEMAND or SPOT
      disk_size      = 10
      disk_type      = "gp3"
      ingress_rules = {
        ssh = {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow SSH from VPC for node3"
        },
        alb = {
          from_port                = 8080
          to_port                  = 8080
          protocol                 = "tcp"
          source_security_group_id = module.external_lb.lb_sg_id
          description              = "Allow traffic from ALB to node2 on port 8080"
        }
      }
    }
  }

  addons = [
    # Add extra addons here if needed
    # Example:
    # {
    #   name = "aws-load-balancer-controller"
    #   version = "v2.7.2"
    # }
  ]
}