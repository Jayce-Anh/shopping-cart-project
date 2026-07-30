############################## DOCDB SECURITY GROUP ##############################

#Security Group
resource "aws_security_group" "sg_db" {
  name        = "${var.project.env}-${var.project.name}-${var.docdb_name}-docdb"
  description = "${var.project.env}-${var.project.name}-${var.docdb_name}-docdb"
  vpc_id      = var.network.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.docdb_name}-docdb"
  })
}

#Security Group Rule
resource "aws_security_group_rule" "sg_rule_from_sg_id" {
  count                    = length(var.allowed_sg_ids_access_docdb)
  type                     = "ingress"
  from_port                = var.docdb_port
  to_port                  = var.docdb_port
  protocol                 = "TCP"
  source_security_group_id = var.allowed_sg_ids_access_docdb[count.index]
  security_group_id        = aws_security_group.sg_db.id
  description              = "Allow access to ${var.docdb_name} from ${var.allowed_sg_ids_access_docdb[count.index]}"
}