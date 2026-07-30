################################ IAM ################################

locals {
  rds_scheduler_enabled = var.rds_scheduler != null
}

#======================== Scheduler IAM Role ==================#
resource "aws_iam_role" "scheduler" {
  count = local.rds_scheduler_enabled ? 1 : 0

  name = "${var.project.env}-${var.project.name}-${var.rds_name}-scheduler-role"
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
    Name = "${var.project.env}-${var.project.name}-${var.rds_name}-scheduler-role"
  })
}

#======================== Scheduler IAM Policy ==================#
resource "aws_iam_role_policy" "scheduler" {
  count = local.rds_scheduler_enabled ? 1 : 0

  name = "${var.project.env}-${var.project.name}-${var.rds_name}-scheduler-policy"
  role = aws_iam_role.scheduler[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["rds:StartDBInstance", "rds:StopDBInstance"]
        Resource = aws_db_instance.db.arn
      }
    ]
  })
}