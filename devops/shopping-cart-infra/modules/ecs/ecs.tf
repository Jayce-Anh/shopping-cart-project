#################################### ECS #####################################

#================== ECS cluster ==================#
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project.env}-${var.project.name}-ecs-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-ecs-cluster"
    Module = "${path.module}"
  })
}

#================== ECS service ==================#
# Auth service
resource "aws_ecs_service" "auth" {
  name                              = "${var.project.env}-${var.project.name}-auth"
  cluster                           = aws_ecs_cluster.ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.auth.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  enable_execute_command            = true
  health_check_grace_period_seconds = 180

  lifecycle {
    create_before_destroy = true
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = var.ecs_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.ecs_target_group_arns["auth"]
    container_name   = "${var.project.env}-${var.project.name}-auth"
    container_port   = 4000
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${each.key}"
    Module = "${path.module}"
  })

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_attachment]
}

# Product service
resource "aws_ecs_service" "product" {
  name                              = "${var.project.env}-${var.project.name}-product"
  cluster                           = aws_ecs_cluster.ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.product.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  enable_execute_command            = true
  health_check_grace_period_seconds = 180

  lifecycle {
    create_before_destroy = true
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = var.ecs_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.ecs_target_group_arns["product"]
    container_name   = "${var.project.env}-${var.project.name}-product"
    container_port   = 5000
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-product"
    Module = "${path.module}"
  })

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_attachment]
}

# Cart service
resource "aws_ecs_service" "cart" {
  name                              = "${var.project.env}-${var.project.name}-cart"
  cluster                           = aws_ecs_cluster.ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.cart.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  enable_execute_command            = true
  health_check_grace_period_seconds = 180

  lifecycle {
    create_before_destroy = true
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = var.ecs_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.ecs_target_group_arns["cart"]
    container_name   = "${var.project.env}-${var.project.name}-cart"
    container_port   = 6000
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-cart"
    Module = "${path.module}"
  })

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_attachment]
}