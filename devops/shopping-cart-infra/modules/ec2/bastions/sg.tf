####################### BASTION SECURITY GROUP #######################

resource "aws_security_group" "bastion" {
  vpc_id      = var.vpc_id
  description = "${var.project.env}-${var.project.name}-bastion"
  name        = "${var.project.env}-${var.project.name}-bastion"

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-bastion"
  })
}

resource "aws_security_group_rule" "ssh_ingress" {
  security_group_id = aws_security_group.bastion.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  description       = "Allow SSH for bastion"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.bastion.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Allow all outbound"
  cidr_blocks       = ["0.0.0.0/0"]
}
