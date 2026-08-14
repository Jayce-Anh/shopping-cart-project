#################################### EKS NODE GROUP ####################################

#================== AMI Release Version ==================#
data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.eks.version}/amazon-linux-2023/x86_64/standard/recommended/release_version"
}

#================== Node Group ==================#
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.project.env}-${var.project.name}-eks-node-group"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.eks_subnet_ids
  ami_type        = "AL2023_x86_64_STANDARD"
  release_version = data.aws_ssm_parameter.eks_ami_release_version.value
  capacity_type   = "SPOT"
  instance_types  = ["t3.medium", "t3a.medium"]

  scaling_config {
    min_size     = 2
    max_size     = 5
    desired_size = 4
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.node_group.id
    version = aws_launch_template.node_group.latest_version
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_group_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_group_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node_group_AmazonSSMManagedInstanceCore,
    aws_iam_role_policy.node_group_kms,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy,
  ]

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-eks-node-group"
  })
}

#================== Node Group Launch Template ==================#
resource "aws_launch_template" "node_group" {
  name = "${var.project.env}-${var.project.name}-eks-node-group"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = var.eks_kms_key
    }
  }

  network_interfaces {
    security_groups             = [aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id, aws_security_group.node_group.id]
    delete_on_termination       = true
    associate_public_ip_address = false
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name           = "${var.project.env}-${var.project.name}-eks-node-group"
      LaunchTemplate = "${var.project.env}-${var.project.name}-eks-node-group"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.tags, {
      Name = "${var.project.env}-${var.project.name}-eks-node-group"
    })
  }
}
