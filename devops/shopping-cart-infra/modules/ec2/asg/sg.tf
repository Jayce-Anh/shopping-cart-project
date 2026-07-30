####################### SECURITY GROUP #######################
resource "aws_security_group" "asg_sg" {
  vpc_id      = var.asg_vpc_id
  description = "${var.project.env}-${var.project.name}-${var.asg_instance_name}-ec2"
  name        = "${var.project.env}-${var.project.name}-${var.asg_instance_name}-ec2"

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.asg_instance_name}-ec2"
  })
}

resource "aws_security_group_rule" "ingress-rule" {
  for_each = var.asg_sg_ingress

  security_group_id = aws_security_group.asg_sg.id
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
  for_each          = var.asg_sg_egress
  security_group_id = aws_security_group.asg_sg.id
  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = each.value.description

  # If cidr_blocks is null, use source_security_group_id; otherwise use cidr_blocks
  source_security_group_id = each.value.cidr_blocks == null ? each.value.source_security_group_id : null
  cidr_blocks              = each.value.cidr_blocks != null ? each.value.cidr_blocks : null
}