################################# VARIABLES #######################################

#================ Project =================#
variable "project" {
  type        = map(string)
  description = "Project metadata (env, name, region, account_ids)"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#================ Alarms =================#
variable "cw_alarm" {
  type = map(object({
    alarm_name                = string
    comparison_operator       = string
    evaluation_periods        = number
    metric_name               = string
    namespace                 = string
    period                    = number
    statistic                 = string
    threshold                 = number
    alarm_description         = optional(string)
    treat_missing_data        = optional(string, "notBreaching")
    datapoints_to_alarm       = optional(number)
    dimensions                = optional(map(string), {})
    alarm_actions             = optional(list(string), [])
    ok_actions                = optional(list(string), [])
    insufficient_data_actions = optional(list(string), [])
    tags                      = optional(map(string), {})
  }))
  default     = {}
  description = "Map of CloudWatch metric alarms to create"
}

#================ Composite Alarms =================#
variable "cw_composite_alarm" {
  type = map(object({
    alarm_name                = string
    alarm_rule                = string
    alarm_description         = optional(string)
    actions_enabled           = optional(bool, true)
    alarm_actions             = optional(list(string), [])
    ok_actions                = optional(list(string), [])
    insufficient_data_actions = optional(list(string), [])
    tags                      = optional(map(string), {})
  }))
  default     = {}
  description = "Map of CloudWatch composite alarms to create"
}

#================ Dashboards =================#
variable "cw_dashboard" {
  type = map(object({
    dashboard_name = string
    dashboard_body = any
  }))
  default     = {}
  description = "Map of CloudWatch dashboards to create"
}

#================ Log Groups =================#
variable "cw_log_group" {
  type = map(object({
    name              = string
    retention_in_days = optional(number)
    kms_key_id        = optional(string)
    tags              = optional(map(string), {})
  }))
  default     = {}
  description = "Map of CloudWatch log groups to create"
}

variable "cw_default_log_retention" {
  type        = number
  default     = 14
  description = "Default log retention in days if not specified per log group"
}

#================ Log Metric Filters =================#
variable "cw_log_metric_filter" {
  type = map(object({
    name           = string
    pattern        = string
    log_group_name = string
    metric_transformation = object({
      name          = string
      namespace     = string
      value         = string
      unit          = optional(string, "None")
      default_value = optional(number)
    })
  }))
  default     = {}
  description = "Map of CloudWatch log metric filters to create"
}

#================ Log-based Alarms =================#
variable "cw_log_based_alarm" {
  type = map(object({
    alarm_name                = string
    comparison_operator       = string
    evaluation_periods        = number
    metric_name               = string
    namespace                 = string
    period                    = number
    statistic                 = string
    threshold                 = number
    alarm_description         = optional(string)
    treat_missing_data        = optional(string, "notBreaching")
    alarm_actions             = optional(list(string), [])
    ok_actions                = optional(list(string), [])
    insufficient_data_actions = optional(list(string), [])
    tags                      = optional(map(string), {})
  }))
  default     = {}
  description = "Map of alarms based on log metric filters"
}

