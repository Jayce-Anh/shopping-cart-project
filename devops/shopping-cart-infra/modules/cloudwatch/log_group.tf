########################### CLOUDWATCH LOG GROUPS #######################################

#====================== CloudWatch Log Groups =======================#
resource "aws_cloudwatch_log_group" "this" {
  for_each = var.cw_log_group

  name              = each.value.name
  retention_in_days = coalesce(each.value.retention_in_days, var.cw_default_log_retention)
  kms_key_id        = lookup(each.value, "kms_key_id", null)

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

#====================== CloudWatch Log Metric Filters =======================#
resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each = var.cw_log_metric_filter

  name           = each.value.name
  pattern        = each.value.pattern
  log_group_name = each.value.log_group_name

  metric_transformation {
    name          = each.value.metric_transformation.name
    namespace     = each.value.metric_transformation.namespace
    value         = each.value.metric_transformation.value
    unit          = lookup(each.value.metric_transformation, "unit", "None")
    default_value = lookup(each.value.metric_transformation, "default_value", null)
  }
}

#====================== CloudWatch Metric Alarms (from Logs) =======================#
resource "aws_cloudwatch_metric_alarm" "log_based" {
  for_each = var.cw_log_based_alarm

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

  alarm_actions             = lookup(each.value, "alarm_actions", [])
  ok_actions                = lookup(each.value, "ok_actions", [])
  insufficient_data_actions = lookup(each.value, "insufficient_data_actions", [])

  tags = merge(var.tags, lookup(each.value, "tags", {}))

  depends_on = [aws_cloudwatch_log_metric_filter.this]
}

