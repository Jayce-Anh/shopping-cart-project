######################## SECURITY GROUP ########################

#================ Security Group =================#
resource "aws_security_group" "sg_db" {
  name        = "${var.project.env}-${var.project.name}-rds"
  description = "${var.project.env}-${var.project.name}-rds"
  vpc_id      = var.rds_vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "TCP"
    security_groups = var.rds_allowed_sg
    description     = "Allow securitys group to access RDS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-rds"
  })
}
