####################### IAM ROLES #######################

resource "aws_iam_role" "ec2_role" {
  name = "${var.project.env}-${var.project.name}-${var.ec2_instance_name}-ec2"
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

#========== Managed Policy Attachments ==========#
locals {
  managed_policies = {
    ssm = {
      enabled    = var.ec2_enable_iam_access.ssm
      policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
    ecr = {
      enabled    = var.ec2_enable_iam_access.ecr
      policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
    }
    s3 = {
      enabled    = var.ec2_enable_iam_access.s3
      policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    }
    ecs = {
      enabled    = var.ec2_enable_iam_access.ecs
      policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
    }
  }

  enabled_managed_policies = {
    for k, v in local.managed_policies : k => v if v.enabled
  }
}

resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each   = local.enabled_managed_policies
  role       = aws_iam_role.ec2_role.name
  policy_arn = each.value.policy_arn
}

#========== Inline Policies (custom permissions) ==========#
resource "aws_iam_role_policy" "secretsmanager_policy" {
  count = var.ec2_enable_iam_access.secretsmanager ? 1 : 0
  name  = "${var.project.env}-${var.project.name}-${var.ec2_instance_name}-fetch-secretsmanager"
  role  = aws_iam_role.ec2_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:${var.project.region}:${var.project.account_ids[0]}:secret:${var.project.env}-${var.project.name}-*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "eks_policy" {
  count = var.ec2_enable_iam_access.eks ? 1 : 0
  name  = "${var.project.env}-${var.project.name}-${var.ec2_instance_name}-fetch-eks"
  role  = aws_iam_role.ec2_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster", "eks:ListClusters"]
        Resource = "*"
      }
    ]
  })
}

#================= Instance Profile ==================#

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project.env}-${var.project.name}-${var.ec2_instance_name}"
  role = aws_iam_role.ec2_role.name
}

#======================== Scheduler IAM Role =========================#
locals {
  ec2_scheduler_enabled = var.ec2_scheduler != null
}

resource "aws_iam_role" "scheduler" {
  count = local.ec2_scheduler_enabled ? 1 : 0

  name = "${var.project.env}-${var.project.name}-${var.ec2_instance_name}-scheduler"
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
    Name = "${var.project.env}-${var.project.name}-${var.ec2_instance_name}-scheduler"
  })
}

resource "aws_iam_role_policy" "scheduler" {
  count = local.ec2_scheduler_enabled ? 1 : 0

  name = "${var.project.env}-${var.project.name}-${var.ec2_instance_name}-scheduler"
  role = aws_iam_role.scheduler[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:StartInstances", "ec2:StopInstances"]
        Resource = aws_instance.ec2.arn
      }
    ]
  })
}
