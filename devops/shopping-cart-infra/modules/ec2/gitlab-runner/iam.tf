########################### GITLAB RUNNER IAM ##########################

#================= Gitlab Runner Instance ==================#
# Roles 
resource "aws_iam_role" "runner" {
  name = "${var.project.env}-${var.project.name}-gitlab-runner"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = ["sts:AssumeRole"]
        Principal = { Service = ["ec2.amazonaws.com"] }
      }
    ]
  })
}

# Attach Policies
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.runner.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.runner.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

#================= Gitlab Runner Instance Profile ==================#
resource "aws_iam_instance_profile" "runner" {
  name = "${var.project.env}-${var.project.name}-gitlab-runner"
  role = aws_iam_role.runner.name
}

#================= Gitlab CI Provider ==================#
# Roles 
resource "aws_iam_role" "ci_provider" {
  name = "${var.project.env}-${var.project.name}-gitlab-ci-provider"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.gitlab.arn}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "gitlab.com:aud" = ["https://gitlab.com"]
          }
          StringLike = {
            "gitlab.com:sub" = ["project_path:${var.project.name}/*"]
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "${aws_iam_role.runner.arn}"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-gitlab-ci-provider"
  })
}

# Attach Policies
resource "aws_iam_role_policy_attachment" "ci_provider_poweruser" {
  role       = aws_iam_role.ci_provider.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role_policy_attachment" "ci_provider_iam" {
  role       = aws_iam_role.ci_provider.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

#================= Scheduler IAM ==================#
# Roles 
resource "aws_iam_role" "scheduler" {
  name = "${var.project.env}-${var.project.name}-gitlab-runner-scheduler"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = { Service = "scheduler.amazonaws.com" }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-gitlab-runner-scheduler"
  })
}

# Attach Policies
resource "aws_iam_role_policy" "scheduler" {
  name = "${var.project.env}-${var.project.name}-gitlab-runner-scheduler"
  role = aws_iam_role.scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:StartInstances", "ec2:StopInstances"]
        Resource = "${aws_instance.runner.arn}"
      }
    ]
  })
}
