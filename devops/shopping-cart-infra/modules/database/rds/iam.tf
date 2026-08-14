################################ IAM ################################

#======================== Scheduler IAM Role ==================#
resource "aws_iam_role" "scheduler" {
  name = "${var.project.env}-${var.project.name}-rds-scheduler"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "scheduler.amazonaws.com"
      } }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-rds-scheduler"
  })
}

#======================== Scheduler IAM Policy ==================#
resource "aws_iam_role_policy" "scheduler" {
  name = "${var.project.env}-${var.project.name}-rds-scheduler"
  role = aws_iam_role.scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["rds:StartDBInstance", "rds:StopDBInstance"]
        Resource = "${aws_db_instance.db.arn}"
      }
    ]
  })
}