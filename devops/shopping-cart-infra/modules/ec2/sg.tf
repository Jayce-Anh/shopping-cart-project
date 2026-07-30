####################### SECURITY GROUP #######################
resource "aws_security_group" "ec2-sg" {
  vpc_id      = var.ec2_vpc_id
  description = "${var.project.env}-${var.project.name}-${var.ec2_instance_name}"
  name        = "${var.project.env}-${var.project.name}-${var.ec2_instance_name}"
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.ec2_instance_name}"
  })
}

resource "aws_security_group_rule" "ingress-rule" {
  for_each = var.ec2_sg_ingress

  security_group_id = aws_security_group.ec2-sg.id
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = each.value.description

  # If cidr_blocks is null, use source_security_group_id; otherwise use cidr_blocks
  source_security_group_id = each.value.cidr_blocks == null ? each.value.source_security_group_id : null
  cidr_blocks              = each.value.cidr_blocks != null ? each.value.cidr_blocks : null
}

resource "aws_security_group_rule" "egress-rule" {
  for_each          = var.ec2_sg_egress
  security_group_id = aws_security_group.ec2-sg.id
  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = each.value.description

  # If cidr_blocks is null, use source_security_group_id; otherwise use cidr_blocks
  source_security_group_id = each.value.cidr_blocks == null ? each.value.source_security_group_id : null
  cidr_blocks              = each.value.cidr_blocks != null ? each.value.cidr_blocks : null
}