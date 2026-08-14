############################# GITLAB RUNNER SCHEDULER #########################

resource "aws_scheduler_schedule" "stop" {
  name       = "Stop-${var.project.env}-${var.project.name}-gitlab-runner"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 12 ? * MON-FRI *)"
  schedule_expression_timezone = "Asia/Singapore"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.scheduler.arn
    input = jsonencode({
      InstanceIds = [aws_instance.runner.id]
    })
  }

  depends_on = [
    aws_instance.runner,
    aws_iam_role_policy.scheduler,
  ]
}

resource "aws_scheduler_schedule" "start" {
  name       = "Start-${var.project.env}-${var.project.name}-gitlab-runner"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 8 ? * MON-FRI *)"
  schedule_expression_timezone = "Asia/Singapore"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.scheduler.arn
    input = jsonencode({
      InstanceIds = [aws_instance.runner.id]
    })
  }

  depends_on = [
    aws_instance.runner,
    aws_iam_role_policy.scheduler,
  ]
}
