############################## ELASTICACHE SECURITY GROUP ##############################

resource "aws_security_group" "sg" {
  name        = "${var.project.env}-${var.project.name}-valkey"
  description = "${var.project.env}-${var.project.name}-valkey"
  vpc_id      = var.cache_vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "TCP"
    security_groups = var.cache_allowed_sg
    description     = "Allow securitys group to access valkey"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-valkey"
  })
}