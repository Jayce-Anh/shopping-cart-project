####################### NODE GROUP SCHEDULER #######################
locals {
  scheduled_node_groups = {
    for k, v in var.node_groups : k => v if v.enable_scheduler == true
  }
}

resource "aws_autoscaling_schedule" "cron_up" {
  for_each = local.scheduled_node_groups

  scheduled_action_name  = "${var.project.env}-${var.project.name}-${local.eks_label}-${each.key}-scale-up"
  min_size               = each.value.cron_up.min
  max_size               = each.value.cron_up.max
  desired_capacity       = each.value.cron_up.desired
  recurrence             = each.value.cron_up.cron
  time_zone              = each.value.cron_up.time_zone
  autoscaling_group_name = aws_eks_node_group.node_groups[each.key].resources[0].autoscaling_groups[0].name

  depends_on = [
    aws_eks_cluster.eks,
    aws_eks_node_group.node_groups,
  ]
}

resource "aws_autoscaling_schedule" "cron_down" {
  for_each = local.scheduled_node_groups

  scheduled_action_name  = "${var.project.env}-${var.project.name}-${local.eks_label}-${each.key}-scale-down"
  min_size               = each.value.cron_down.min
  max_size               = each.value.cron_down.max
  desired_capacity       = each.value.cron_down.desired
  recurrence             = each.value.cron_down.cron
  time_zone              = each.value.cron_down.time_zone
  autoscaling_group_name = aws_eks_node_group.node_groups[each.key].resources[0].autoscaling_groups[0].name

  depends_on = [
    aws_eks_cluster.eks,
    aws_eks_node_group.node_groups,
  ]
}
