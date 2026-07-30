############################# EC2 INSTANCE SCHEDULER #########################
resource "aws_scheduler_schedule" "stop_ec2" {
  count = local.ec2_scheduler_enabled ? 1 : 0

  name       = "Stop-${var.project.env}-${var.project.name}-${var.ec2_instance_name}"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.ec2_scheduler.cron_stop
  schedule_expression_timezone = var.ec2_scheduler.timezone

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.scheduler[0].arn
    input = jsonencode({
      InstanceIds = [aws_instance.ec2.id]
    })
  }

  depends_on = [
    aws_instance.ec2,
    aws_iam_role_policy.scheduler,
  ]
}

resource "aws_scheduler_schedule" "start_ec2" {
  count = local.ec2_scheduler_enabled ? 1 : 0

  name       = "Start-${var.project.env}-${var.project.name}-${var.ec2_instance_name}"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.ec2_scheduler.cron_start
  schedule_expression_timezone = var.ec2_scheduler.timezone

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.scheduler[0].arn
    input = jsonencode({
      InstanceIds = [aws_instance.ec2.id]
    })
  }

  depends_on = [
    aws_instance.ec2,
    aws_iam_role_policy.scheduler,
  ]
}
