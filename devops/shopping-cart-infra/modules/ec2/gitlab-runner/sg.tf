####################### GITLAB RUNNER SECURITY GROUP #######################

resource "aws_security_group" "runner" {
  vpc_id      = var.vpc_id
  description = "${var.project.env}-${var.project.name}-gitlab-runner"
  name        = "${var.project.env}-${var.project.name}-gitlab-runner"

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-gitlab-runner"
  })
}

resource "aws_security_group_rule" "ingress" {
  security_group_id = aws_security_group.runner.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  description       = "Allow SSH for GitLab runner"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.runner.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Allow all outbound"
  cidr_blocks       = ["0.0.0.0/0"]
}
