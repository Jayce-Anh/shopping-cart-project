####################### ASG SCHEDULER #######################

resource "aws_autoscaling_schedule" "cron_up" {
  count = var.asg_scheduler_up != null ? 1 : 0

  scheduled_action_name  = "${var.project.env}-${var.project.name}-${var.asg_instance_name}-scale-up"
  min_size               = var.asg_scheduler_up.min
  max_size               = var.asg_scheduler_up.max
  desired_capacity       = var.asg_scheduler_up.desired
  recurrence             = var.asg_scheduler_up.cron
  time_zone              = var.asg_scheduler_up.time_zone
  autoscaling_group_name = aws_autoscaling_group.asg.name

  depends_on = [
    aws_autoscaling_group.asg,
  ]
}

resource "aws_autoscaling_schedule" "cron_down" {
  count = var.asg_scheduler_down != null ? 1 : 0

  scheduled_action_name  = "${var.project.env}-${var.project.name}-${var.asg_instance_name}-scale-down"
  min_size               = var.asg_scheduler_down.min
  max_size               = var.asg_scheduler_down.max
  desired_capacity       = var.asg_scheduler_down.desired
  recurrence             = var.asg_scheduler_down.cron
  time_zone              = var.asg_scheduler_down.time_zone
  autoscaling_group_name = aws_autoscaling_group.asg.name

  depends_on = [
    aws_autoscaling_group.asg,
  ]
}
