######################## SECURITY GROUP ########################
# Note: EKS auto-creates the cluster security group - we don't need to create or manage it
# The auto-created cluster SG handles all basic EKS communication automatically

################### Security Group for EKS Fargate Node Group ########################
resource "aws_security_group" "eks_fargate_node_group_sg" {
  name        = format("%s-eks-fargate-node-group-sg", var.eks_name)
  description = "Security group for EKS fargate node group - only custom rules"
  vpc_id      = var.vpc_id

  # Outbound traffic (required for downloading images, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  # Note: Basic EKS communication is handled by the auto-created cluster security group
  # Only add custom application-specific rules here via fargate_sg_ingress variable

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.eks_name}-fargate-sg"
  })
}

#extra ingress rules
resource "aws_security_group_rule" "eks_fargate_node_group_sg_ingress_extra" {
  for_each = { for v in var.fargate_sg_ingress : v.name => v }

  security_group_id = aws_security_group.eks_fargate_node_group_sg.id
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  description       = each.value.description
}