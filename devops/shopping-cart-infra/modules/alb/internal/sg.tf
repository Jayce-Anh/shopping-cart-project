############################ INTERNAL ALB SECURITY GROUP ############################

resource "aws_security_group" "sg_lb" {
  name        = "${var.project.env}-${var.project.name}-internal"
  description = "SG of internal ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    description = ""
    cidr_blocks = var.source_ingress_sg_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-internal"
  })
}