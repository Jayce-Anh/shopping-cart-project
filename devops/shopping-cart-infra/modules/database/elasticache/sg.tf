############################## ELASTICACHE SECURITY GROUP ##############################

resource "aws_security_group" "sg" {
  name        = "${var.project.env}-${var.project.name}-${var.cache_name}"
  description = "${var.project.env}-${var.project.name}-${var.cache_name}"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.cache_name}"
  })
}

# Security group rule
resource "aws_security_group_rule" "sg_rule_cache_from_sg_ids" {
  count = length(var.allowed_sg_ids_access_cache)

  type                     = "ingress"
  from_port                = var.cache_port
  to_port                  = var.cache_port
  protocol                 = "TCP"
  source_security_group_id = var.allowed_sg_ids_access_cache[count.index]
  security_group_id        = aws_security_group.sg.id
  description              = "Allow access to ${var.cache_name} from ${var.allowed_sg_ids_access_cache[count.index]}"
}

resource "aws_security_group_rule" "sg_rule_cache_from_cidr_blocks" {
  count = length(var.allowed_cidr_blocks_access_cache)

  type              = "ingress"
  from_port         = var.cache_port
  to_port           = var.cache_port
  protocol          = "TCP"
  cidr_blocks       = var.allowed_cidr_blocks_access_cache
  security_group_id = aws_security_group.sg.id
  description       = "Allow access to ${var.cache_name} from ${var.allowed_cidr_blocks_access_cache[count.index]}"
}