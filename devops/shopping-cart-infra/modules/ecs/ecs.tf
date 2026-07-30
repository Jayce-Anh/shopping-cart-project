################################# ECS #######################################

#==================== ECS cluster ======================#
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project.env}-${var.project.name}-ecs-cluster"
  setting {
    name  = "containerInsights"
    value = var.containerInsights
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-ecs-cluster"
  })
}

#==================== ECS task definition ======================#
resource "aws_ecs_task_definition" "ecs_task" {
  for_each = {
    for k, v in var.task_definitions : k => v
  }
  family                   = "${var.project.env}-${var.project.name}-${each.value.container_name}-task"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskRole.arn
  network_mode             = var.network_mode
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  container_definitions = templatefile("${path.module}/container_def.json.tpl", {
    region            = var.project.region
    env               = var.project.env
    project           = var.project.name
    container_name    = each.value.container_name
    container_image   = each.value.container_image
    cpu               = each.value.cpu
    memory            = each.value.memory
    container_port    = each.value.container_port
    host_port         = each.value.host_port
    health_check_path = each.value.health_check_path
  })
}

#==================== ECS service ======================#
resource "aws_ecs_service" "service" {
  for_each = var.task_definitions

  name                   = "${var.project.env}-${var.project.name}-${each.value.container_name}"
  cluster                = aws_ecs_cluster.ecs_cluster.id
  task_definition        = aws_ecs_task_definition.ecs_task[each.key].arn
  desired_count          = each.value.desired_count
  launch_type            = each.value.launch_type
  enable_execute_command = true

  # Add health check grace period for ALB
  health_check_grace_period_seconds = 180 # 3 minutes for container to start

  # Force replacement when network configuration changes
  lifecycle {
    create_before_destroy = true
  }

  network_configuration {
    security_groups  = each.value.enable_load_balancer ? [aws_security_group.ecs_tasks.id] : [aws_security_group.ecs_tasks_without_ALB.id]
    subnets          = var.subnets
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    # ALB target group must change the target type to IP for container
    for_each = each.value.load_balancer != null ? [each.value.load_balancer] : []

    content {
      target_group_arn = var.target_group_arn
      container_name   = "${var.project.env}-${var.project.name}-${each.value.container_name}"
      container_port   = each.value.load_balancer.container_port
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${each.value.container_name}"
  })

  depends_on = [aws_iam_role_policy_attachment.ecsTaskExecutionRole_policy]
}
