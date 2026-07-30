################################# IAM #######################################
#--------------ECS task execution role ----------------
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.project.env}-${var.project.name}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-execution-task-role"
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

#--------------ECS task execution role policy attachment ----------------
resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

#--------------ECS task role ----------------
resource "aws_iam_role" "ecsTaskRole" {
  name               = "${var.project.env}-${var.project.name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-ecs-task-role"
  })
}

#--------------ECS task role policy ----------------
resource "aws_iam_policy" "ecs_task_role_policy" {
  name = "${var.project.env}-${var.project.name}-ecs_exec_policy"

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
        Effect = "Allow"
        # Use the first account ID from the project configuration
        Resource = "arn:aws:logs:${var.project.region}:${var.project.account_ids[0]}:log-group:/ecs/*"
      },
      {
        Action   = ["logs:DescribeLogGroups"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

#--------------ECS task role policy attachment ----------------
resource "aws_iam_role_policy_attachment" "ecsTaskRole_policy" {
  role       = aws_iam_role.ecsTaskRole.name
  policy_arn = aws_iam_policy.ecs_task_role_policy.arn
}

#--------------ECS task role policy attachment ----------------
resource "aws_iam_role_policy" "ecsTaskExecutionRole_ssm_policy" {
  name = "${var.project.env}-${var.project.name}-ecs-task-execution-ssm-policy"
  role = aws_iam_role.ecsTaskExecutionRole.id

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
