locals {
  #========================= EKS AMI SSM Paths =========================#
  eks_ami_ssm_paths = {
    AL2_x86_64             = "amazon-linux-2/x86_64/standard"
    AL2_x86_64_GPU         = "amazon-linux-2/x86_64/nvidia"
    AL2_ARM_64             = "amazon-linux-2/arm64/standard"
    AL2023_x86_64_STANDARD = "amazon-linux-2023/x86_64/standard"
    AL2023_ARM_64_STANDARD = "amazon-linux-2023/arm64/standard"
    AL2023_x86_64_NVIDIA   = "amazon-linux-2023/x86_64/nvidia"
    AL2023_ARM_64_NVIDIA   = "amazon-linux-2023/arm64/nvidia"
  }

  #========================= Node Group AMI Types =========================#
  node_group_ami_types = {
    for k, v in var.node_groups :
    k => lookup(v, "ami_type", "AL2023_x86_64_STANDARD")
  }

  #========================= EKS AMI Release Version AMI Types =========================#
  eks_ami_release_version_ami_types = toset([
    for ami_type in values(local.node_group_ami_types) :
    ami_type
    if contains(keys(local.eks_ami_ssm_paths), ami_type)
  ])
}

#========================= EKS AMI Release Version =========================#
data "aws_ssm_parameter" "eks_ami_release_version" {
  for_each = local.eks_ami_release_version_ami_types

  name = "/aws/service/eks/optimized-ami/${var.eks_version}/${local.eks_ami_ssm_paths[each.key]}/recommended/release_version"
}
