module "eks" {
  source                       = "./modules/eks/fargate"
  project                      = local.project
  tags                         = local.tags
  vpc_id                       = local.network.vpc_id
  eks_version                  = "1.31"
  eks_name                     = "lab"
  eks_subnet                   = local.network.private_subnet_ids
  endpoint_private_access      = true
  endpoint_public_access       = true
  endpoint_public_access_cidrs = ["0.0.0.0/0"] # Your office ip or office cidr

  # Fargate Profile
  fargates = {
    node1 = {
      subnet_ids    = [local.network.private_subnet_ids[0]]
      min_size      = 1
      max_size      = 3
      desired_size  = 2
      instance_type = "t3.small"
      disk_size     = 10
      disk_type     = "gp3"
    }

    node2 = {
      subnet_ids    = [local.network.private_subnet_ids[1]]
      min_size      = 1
      max_size      = 3
      desired_size  = 2
      instance_type = "t3.small"
      disk_size     = 10
      disk_type     = "gp3"
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