################################# CLOUDWATCH ALARMS #######################################

#====================== CloudWatch Alarms =======================#
resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = var.cw_alarm

  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = lookup(each.value, "alarm_description", null)
  treat_missing_data  = lookup(each.value, "treat_missing_data", "notBreaching")
  datapoints_to_alarm = lookup(each.value, "datapoints_to_alarm", null)

  dimensions = lookup(each.value, "dimensions", {})

  alarm_actions             = lookup(each.value, "alarm_actions", [])
  ok_actions                = lookup(each.value, "ok_actions", [])
  insufficient_data_actions = lookup(each.value, "insufficient_data_actions", [])

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

#====================== Composite Alarms =======================#
resource "aws_cloudwatch_composite_alarm" "this" {
  for_each = var.cw_composite_alarm

  alarm_name        = each.value.alarm_name
  alarm_description = lookup(each.value, "alarm_description", null)
  alarm_rule        = each.value.alarm_rule
  actions_enabled   = lookup(each.value, "actions_enabled", true)

  alarm_actions             = lookup(each.value, "alarm_actions", [])
  ok_actions                = lookup(each.value, "ok_actions", [])
  insufficient_data_actions = lookup(each.value, "insufficient_data_actions", [])

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

