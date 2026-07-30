####################### RDS SCHEDULER #######################

resource "aws_scheduler_schedule" "stop_database" {
  count = local.rds_scheduler_enabled ? 1 : 0

  name       = "Stop-${var.project.env}-${var.project.name}-${var.rds_name}"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.rds_scheduler.cron_stop
  schedule_expression_timezone = var.rds_scheduler.timezone

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:stopDBInstance"
    role_arn = aws_iam_role.scheduler[0].arn
    input = jsonencode({
      DbInstanceIdentifier = aws_db_instance.db.identifier
    })
  }

  depends_on = [
    aws_db_instance.db,
    aws_iam_role_policy.scheduler,
  ]
}

resource "aws_scheduler_schedule" "start_database" {
  count = local.rds_scheduler_enabled ? 1 : 0

  name       = "Start-${var.project.env}-${var.project.name}-${var.rds_name}"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.rds_scheduler.cron_start
  schedule_expression_timezone = var.rds_scheduler.timezone

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:startDBInstance"
    role_arn = aws_iam_role.scheduler[0].arn
    input = jsonencode({
      DbInstanceIdentifier = aws_db_instance.db.identifier
    })
  }

  depends_on = [
    aws_db_instance.db,
    aws_iam_role_policy.scheduler,
  ]
}
