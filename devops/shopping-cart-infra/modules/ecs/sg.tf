############################# SECURITY GROUP ##############################

#=============== ECS task with ALB security group ===============#
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project.env}-${var.project.name}-${var.ecs_cluster_name}"
  description = "Allow inbound access from the ALB only"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.ecs_cluster_name}"
  })
}

#=============== Ingress rule ===============#
resource "aws_vpc_security_group_ingress_rule" "ecs_ingress" {
  for_each = {
    for k, v in var.task_definitions : k => v if v.enable_load_balancer
  }
  security_group_id            = aws_security_group.ecs_tasks.id
  referenced_security_group_id = var.lb_sg_id
  from_port                    = each.value.load_balancer.target_group_port
  ip_protocol                  = "tcp"
  to_port                      = each.value.load_balancer.container_port
}

#=============== Egress rule ===============#
resource "aws_vpc_security_group_egress_rule" "ecs_egress" {
  security_group_id = aws_security_group.ecs_tasks.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#=============== ECS task without ALB security group ===============#
resource "aws_security_group" "ecs_tasks_without_ALB" {
  name        = "${var.project.env}-${var.project.name}-${var.ecs_cluster_name}-ecs-tasks-without-ALB"
  description = "Allow outbound access to any"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.ecs_cluster_name}-ecs-tasks-without-ALB"
  })
}

#=============== Egress rule ===============#
resource "aws_vpc_security_group_egress_rule" "ecs_non_ALB_egress" {
  security_group_id = aws_security_group.ecs_tasks_without_ALB.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}