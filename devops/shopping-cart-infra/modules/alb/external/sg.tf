########################### LOAD BALANCER SECURITY GROUP ###########################
resource "aws_security_group" "sg_lb" {
  name        = "${var.project.env}-${var.project.name}-${var.alb_name}"
  description = "SG of ALB"
  vpc_id      = var.alb_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    description = "Allow HTTP from internet"
    cidr_blocks = var.alb_source_ingress_sg_cidr
  }

  dynamic "ingress" {
    for_each = var.alb_dns_cert != null ? [1] : []
    content {
      from_port   = 443
      to_port     = 443
      protocol    = "TCP"
      description = "Allow HTTPS from internet"
      cidr_blocks = var.alb_source_ingress_sg_cidr
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.alb_name}"
  })
}