######################## EKS SECURITY GROUPS ########################

#========================== Node Group Security Group ===========================#
resource "aws_security_group" "node_group" {
  name_prefix = "${var.project.env}-${var.project.name}-eks-node-"
  description = "Security group for EKS node group"
  vpc_id      = var.eks_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-eks-node-group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Allow nodes to talk to each other
resource "aws_security_group_rule" "node_group_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.node_group.id
  description       = "Allow node-to-node communication"
}

# Allow cluster security group to reach nodes
resource "aws_security_group_rule" "node_group_from_cluster" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
  security_group_id        = aws_security_group.node_group.id
  description              = "Allow traffic from EKS cluster security group"
}

# Allow external ALB to reach service / platform pods (match old node_groups.ingress_rules)
resource "aws_security_group_rule" "node_group_from_alb_services" {
  type                     = "ingress"
  from_port                = 4000
  to_port                  = 6000
  protocol                 = "tcp"
  source_security_group_id = var.eks_alb_sg_id
  security_group_id        = aws_security_group.node_group.id
  description              = "Allow traffic from external ALB to service pods"
}

resource "aws_security_group_rule" "node_group_from_alb_argocd" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = var.eks_alb_sg_id
  security_group_id        = aws_security_group.node_group.id
  description              = "Allow traffic from external ALB to ArgoCD pods"
}

resource "aws_security_group_rule" "node_group_from_alb_grafana" {
  type                     = "ingress"
  from_port                = 8090
  to_port                  = 8090
  protocol                 = "tcp"
  source_security_group_id = var.eks_alb_sg_id
  security_group_id        = aws_security_group.node_group.id
  description              = "Allow traffic from external ALB to Grafana pods"
}

resource "aws_security_group_rule" "node_group_from_alb_kibana" {
  type                     = "ingress"
  from_port                = 5601
  to_port                  = 5601
  protocol                 = "tcp"
  source_security_group_id = var.eks_alb_sg_id
  security_group_id        = aws_security_group.node_group.id
  description              = "Allow traffic from external ALB to Kibana pods"
}

#========================== Cluster API Access ===========================#
resource "aws_security_group_rule" "cluster_ingress_from_sg" {
  count = length(var.eks_allowed_sg)

  type                     = "ingress"
  security_group_id        = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
  from_port                = 443
  to_port                  = 443
  protocol                 = "TCP"
  source_security_group_id = var.eks_allowed_sg[count.index]
  description              = "Allow EKS API access from ${var.eks_allowed_sg[count.index]}"

  depends_on = [aws_eks_cluster.eks]
}
