####################### RDS SCHEDULER #######################

resource "aws_scheduler_schedule" "stop" {
  name       = "Stop-${var.project.env}-${var.project.name}-rds"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 12 * * ? *)" # 12:00 PM
  schedule_expression_timezone = "Asia/Singapore"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:stopDBInstance"
    role_arn = aws_iam_role.scheduler.arn
    input = jsonencode({
      DbInstanceIdentifier = "${aws_db_instance.db.identifier}"
    })
  }

  depends_on = [
    aws_db_instance.db,
    aws_iam_role_policy.scheduler,
  ]
}

resource "aws_scheduler_schedule" "start" {
  name       = "Start-${var.project.env}-${var.project.name}-rds"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 8 * * ? *)" # 8:00 AM
  schedule_expression_timezone = "Asia/Singapore"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:startDBInstance"
    role_arn = aws_iam_role.scheduler.arn
    input = jsonencode({
      DbInstanceIdentifier = "${aws_db_instance.db.identifier}"
    })
  }

  depends_on = [
    aws_db_instance.db,
    aws_iam_role_policy.scheduler,
  ]
}
