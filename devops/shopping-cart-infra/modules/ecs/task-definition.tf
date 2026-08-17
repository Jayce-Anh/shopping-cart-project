################################### ECS TASK DEFINITION #######################################

# Auth service
resource "aws_ecs_task_definition" "auth" {
  family                   = "${var.project.env}-${var.project.name}-auth"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name      = "${var.project.env}-${var.project.name}-auth"
      image     = "${module.ecr.ecr_url["auth"]}:latest"
      cpu       = "${aws_ecs_task_definition.auth.cpu}"
      memory    = "${aws_ecs_task_definition.auth.memory}"
      essential = true
      portMappings = [
        {
          containerPort = 4000
          hostPort      = 4000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.auth.name}"
          awslogs-region        = "${var.project.region}"
          awslogs-stream-prefix = "ecs"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:4000/health || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 180
      }
      liveParameters = {
        initProcessEnabled = true
      }
    }
  ])

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-auth"
    Module = "${path.module}"
  })
}

# Product service
resource "aws_ecs_task_definition" "product" {
  family                   = "${var.project.env}-${var.project.name}-product"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name      = "${var.project.env}-${var.project.name}-product"
      image     = "${module.ecr.ecr_url["product"]}:latest"
      cpu       = "${aws_ecs_task_definition.product.cpu}"
      memory    = "${aws_ecs_task_definition.product.memory}"
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.product.name}"
          awslogs-region        = "${var.project.region}"
          awslogs-stream-prefix = "ecs"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:5000/health || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 180
      }
      liveParameters = {
        initProcessEnabled = true
      }
    }
  ])

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-product"
    Module = "${path.module}"
  })
}

# Cart service
resource "aws_ecs_task_definition" "cart" {
  family                   = "${var.project.env}-${var.project.name}-cart"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name      = "${var.project.env}-${var.project.name}-cart"
      image     = "${module.ecr.ecr_url["cart"]}:latest"
      cpu       = "${aws_ecs_task_definition.cart.cpu}"
      memory    = "${aws_ecs_task_definition.cart.memory}"
      essential = true
      portMappings = [
        {
          containerPort = 6000
          hostPort      = 6000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.cart.name}"
          awslogs-region        = "${var.project.region}"
          awslogs-stream-prefix = "ecs"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:6000/health || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 180
      }
      liveParameters = {
        initProcessEnabled = true
      }
    }
  ])

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-cart"
    Module = "${path.module}"
  })
}