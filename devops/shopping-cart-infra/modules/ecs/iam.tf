################################# ECS IAM ######################################

#================== Roles ==================#
# Execution role
resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.project.env}-${var.project.name}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-execution-task-role"
    Module = "${path.module}"
  })
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Task role
resource "aws_iam_role" "ecs_task" {
  name               = "${var.project.env}-${var.project.name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-ecs-task-role"
    Module = "${path.module}"
  })
}

#================== Policy Attachments ==================#
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_attachment" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task.arn
}

#================== Policies ==================#
resource "aws_iam_policy" "ecs_task" {
  name = "${var.project.env}-${var.project.name}-ecs-task"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = ["logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${var.project.region}:${var.project.account_id}:log-group:/ecs/*"
      },
      {
        Action   = ["logs:DescribeLogGroups"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


# SSM policy
resource "aws_iam_role_policy" "ecs_task_ssm" {
  name = "${var.project.env}-${var.project.name}-ecs-task-ssm"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ]
        Resource = "*"
      }
    ]
  })
}