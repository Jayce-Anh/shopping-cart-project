################################# ECS SECURITY GROUP #######################################

#================== ECS task ==================#
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project.env}-${var.project.name}-ecs-tasks"
  description = "Security group for ECS tasks"
  vpc_id      = var.ecs_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound access to all ports"
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-ecs-tasks"
    Module = "${path.module}"
  })
}

#================== Ingress Rules ==================#
resource "aws_security_group_rule" "auth_ingress" {
  security_group_id        = aws_security_group.ecs_tasks.id
  type                     = "ingress"
  from_port                = 4000
  to_port                  = 4000
  protocol                 = "tcp"
  source_security_group_id = var.ecs_lb_sg_id
  description              = "Allow inbound access from the Load Balancer for auth service"
}

resource "aws_security_group_rule" "product_ingress" {
  security_group_id        = aws_security_group.ecs_tasks.id
  type                     = "ingress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  source_security_group_id = var.ecs_lb_sg_id
  description              = "Allow inbound access from the Load Balancer for product service"
}

resource "aws_security_group_rule" "cart_ingress" {
  security_group_id        = aws_security_group.ecs_tasks.id
  type                     = "ingress"
  from_port                = 6000
  to_port                  = 6000
  protocol                 = "tcp"
  source_security_group_id = var.ecs_lb_sg_id
  description              = "Allow inbound access from the Load Balancer for cart service"
}