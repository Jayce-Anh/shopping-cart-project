######################## SECURITY GROUP ########################

#================ Security Group =================#
resource "aws_security_group" "sg_db" {
  name        = "${var.project.env}-${var.project.name}-${var.rds_name}-rds"
  description = "${var.project.env}-${var.project.name}-${var.rds_name}-rds"
  vpc_id      = var.rds_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.rds_name}-rds"
  })
}

#================ Security Group Rule =================#
resource "aws_security_group_rule" "sg_rule_from_sg_id" {
  count                    = length(var.rds_allowed_sg_ids_access)
  type                     = "ingress"
  from_port                = var.rds_port
  to_port                  = var.rds_port
  protocol                 = "TCP"
  source_security_group_id = var.rds_allowed_sg_ids_access[count.index]
  security_group_id        = aws_security_group.sg_db.id
  description              = "Allow access to ${var.rds_name} from ${var.rds_allowed_sg_ids_access[count.index]}"
}