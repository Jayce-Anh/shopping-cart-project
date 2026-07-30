######################## EKS SECURITY GROUPS ########################

locals {
  public_alb_sg_name = "${var.project.env}-${var.project.name}-${local.eks_label}-eks-public-alb"
  public_alb_enabled = length(var.eks_public_alb_sg_ingress) > 0
}

#========================== Node Group Security Group ===========================#
resource "aws_security_group" "node_groups" {
  for_each = var.node_groups

  name_prefix = "${var.project.env}-${var.project.name}-${local.eks_label}-${each.key}-node-group"
  description = "Security group for EKS node group ${each.key}"
  vpc_id      = var.eks_vpc

  dynamic "egress" {
    for_each = each.value.egress_rules
    iterator = rule

    content {
      from_port   = rule.value.from_port
      to_port     = rule.value.to_port
      protocol    = rule.value.protocol
      cidr_blocks = lookup(rule.value, "cidr_blocks", null)
      description = lookup(rule.value, "description", null)
    }
  }

  # App ALB and other node-group ingress 
  dynamic "ingress" {
    for_each = lookup(each.value, "ingress_rules", {})
    iterator = rule

    content {
      from_port       = rule.value.from_port
      to_port         = rule.value.to_port
      protocol        = rule.value.protocol
      cidr_blocks     = lookup(rule.value, "cidr_blocks", null)
      security_groups = lookup(rule.value, "source_security_group_id", null) != null ? [rule.value.source_security_group_id] : null
      self            = lookup(rule.value, "self", null)
      description     = lookup(rule.value, "description", null)
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${local.eks_label}-${each.key}-node-group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

#========================== Cluster API Access ===========================#
resource "aws_security_group_rule" "cluster_ingress" {
  for_each = var.eks_sg_ingress.ingress_rules

  type              = "ingress"
  security_group_id = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = lookup(each.value, "description", null)

  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  cidr_blocks              = lookup(each.value, "source_security_group_id", null) == null ? lookup(each.value, "cidr_blocks", null) : null
  self                     = lookup(each.value, "self", null)

  depends_on = [aws_eks_cluster.eks]
}

#========================== Shared EKS Ingress ALB ===========================#
data "aws_security_groups" "existing_public_alb" {
  count = local.public_alb_enabled ? 1 : 0

  filter {
    name   = "group-name"
    values = [local.public_alb_sg_name]
  }

  filter {
    name   = "vpc-id"
    values = [var.eks_vpc]
  }
}

resource "aws_security_group" "public_alb" {
  count = local.public_alb_enabled && length(data.aws_security_groups.existing_public_alb[0].ids) == 0 ? 1 : 0

  name        = local.public_alb_sg_name
  description = "Security group for shared internet-facing Helm ALB"
  vpc_id      = var.eks_vpc

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name = local.public_alb_sg_name
  })

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  public_alb_sg_id = local.public_alb_enabled ? (
    length(data.aws_security_groups.existing_public_alb[0].ids) > 0
    ? data.aws_security_groups.existing_public_alb[0].ids[0]
    : aws_security_group.public_alb[0].id
  ) : null
}

resource "aws_security_group_rule" "public_alb_ingress" {
  for_each = var.eks_public_alb_sg_ingress

  type              = "ingress"
  security_group_id = local.public_alb_sg_id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = each.value.description

  source_security_group_id = each.value.cidr_blocks == null ? each.value.source_security_group_id : null
  cidr_blocks              = each.value.cidr_blocks != null ? each.value.cidr_blocks : null
}

resource "aws_security_group_rule" "public_alb_to_nodes_ingress" {
  for_each = local.public_alb_enabled ? {
    for pair in setproduct(keys(var.eks_public_alb_to_nodes_ingress), keys(aws_security_group.node_groups)) :
    "${pair[0]}-${pair[1]}" => {
      rule_key       = pair[0]
      node_group_key = pair[1]
    }
  } : {}

  type              = "ingress"
  security_group_id = aws_security_group.node_groups[each.value.node_group_key].id
  from_port         = var.eks_public_alb_to_nodes_ingress[each.value.rule_key].from_port
  to_port           = var.eks_public_alb_to_nodes_ingress[each.value.rule_key].to_port
  protocol          = var.eks_public_alb_to_nodes_ingress[each.value.rule_key].protocol
  description       = var.eks_public_alb_to_nodes_ingress[each.value.rule_key].description

  source_security_group_id = local.public_alb_sg_id
}
