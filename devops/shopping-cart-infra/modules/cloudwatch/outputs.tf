################################# OUTPUTS #######################################

#====================== Alarms =======================#
output "alarm_arns" {
  description = "ARNs of created CloudWatch alarms"
  value       = { for k, v in aws_cloudwatch_metric_alarm.this : k => v.arn }
}

output "alarm_ids" {
  description = "IDs of created CloudWatch alarms"
  value       = { for k, v in aws_cloudwatch_metric_alarm.this : k => v.id }
}

#====================== Composite Alarms =======================#
output "composite_alarm_arns" {
  description = "ARNs of created CloudWatch composite alarms"
  value       = { for k, v in aws_cloudwatch_composite_alarm.this : k => v.arn }
}

#====================== Dashboards =======================#
output "dashboard_arns" {
  description = "ARNs of created CloudWatch dashboards"
  value       = { for k, v in aws_cloudwatch_dashboard.this : k => v.dashboard_arn }
}

output "dashboard_names" {
  description = "Names of created CloudWatch dashboards"
  value       = { for k, v in aws_cloudwatch_dashboard.this : k => v.dashboard_name }
}

#====================== Log Groups =======================#
output "log_group_arns" {
  description = "ARNs of created CloudWatch log groups"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.arn }
}

output "log_group_names" {
  description = "Names of created CloudWatch log groups"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.name }
}

#====================== Log Metric Filters =======================#
output "log_metric_filter_ids" {
  description = "IDs of created log metric filters"
  value       = { for k, v in aws_cloudwatch_log_metric_filter.this : k => v.id }
}

#====================== Log-based Alarms =======================#
output "log_based_alarm_arns" {
  description = "ARNs of log-based CloudWatch alarms"
  value       = { for k, v in aws_cloudwatch_metric_alarm.log_based : k => v.arn }
}

