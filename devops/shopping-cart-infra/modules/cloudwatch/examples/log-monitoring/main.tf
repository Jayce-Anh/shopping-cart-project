################################# EXAMPLE: Log Monitoring #######################################

# SNS Topic for alerts
resource "aws_sns_topic" "log_alerts" {
  name = "prod-log-alerts"
}

module "log_monitoring" {
  source = "../../"

  tags = {
    Name = "prod-log-monitoring"
  }

  # Create log groups
  log_groups = {
    application = {
      name              = "/aws/application/prod"
      retention_in_days = 30
    }
    api = {
      name              = "/aws/api/prod"
      retention_in_days = 14
    }
  }

  # Extract metrics from logs
  log_metric_filters = {
    # Count ERROR level logs
    error_count = {
      name           = "ErrorCount"
      pattern        = "[time, request_id, level = ERROR*, ...]"
      log_group_name = "/aws/application/prod"

      metric_transformation = {
        name      = "ErrorCount"
        namespace = "CustomApp/Logs"
        value     = "1"
        unit      = "Count"
      }
    }

    # Count WARN level logs
    warning_count = {
      name           = "WarningCount"
      pattern        = "[time, request_id, level = WARN*, ...]"
      log_group_name = "/aws/application/prod"

      metric_transformation = {
        name      = "WarningCount"
        namespace = "CustomApp/Logs"
        value     = "1"
        unit      = "Count"
      }
    }

    # Track API response times
    api_response_time = {
      name           = "APIResponseTime"
      pattern        = "[timestamp, request_id, method, path, status_code, response_time]"
      log_group_name = "/aws/api/prod"

      metric_transformation = {
        name      = "APIResponseTime"
        namespace = "CustomApp/API"
        value     = "$response_time"
        unit      = "Milliseconds"
      }
    }

    # Count 5xx status codes
    api_5xx_count = {
      name           = "API5xxCount"
      pattern        = "[timestamp, request_id, method, path, status_code = 5*, response_time]"
      log_group_name = "/aws/api/prod"

      metric_transformation = {
        name      = "API5xxCount"
        namespace = "CustomApp/API"
        value     = "1"
        unit      = "Count"
      }
    }
  }

  # Create alarms based on log metrics
  log_based_alarms = {
    high_error_rate = {
      alarm_name          = "prod-high-error-rate"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 1
      metric_name         = "ErrorCount"
      namespace           = "CustomApp/Logs"
      period              = 300
      statistic           = "Sum"
      threshold           = 10
      alarm_description   = "More than 10 errors in 5 minutes"
      treat_missing_data  = "notBreaching"

      alarm_actions = [aws_sns_topic.log_alerts.arn]
    }

    api_errors = {
      alarm_name          = "prod-api-5xx-errors"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "API5xxCount"
      namespace           = "CustomApp/API"
      period              = 60
      statistic           = "Sum"
      threshold           = 5
      alarm_description   = "API returning 5xx errors"
      datapoints_to_alarm = 2

      alarm_actions = [aws_sns_topic.log_alerts.arn]
    }

    slow_api_response = {
      alarm_name          = "prod-slow-api-response"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 3
      metric_name         = "APIResponseTime"
      namespace           = "CustomApp/API"
      period              = 300
      statistic           = "Average"
      threshold           = 1000 # 1 second
      alarm_description   = "API response time is high"

      alarm_actions = [aws_sns_topic.log_alerts.arn]
    }
  }

  # Dashboard for log metrics
  dashboards = {
    log_metrics = {
      dashboard_name = "prod-log-metrics"
      dashboard_body = {
        widgets = [
          {
            type = "metric"
            properties = {
              metrics = [
                ["CustomApp/Logs", "ErrorCount"],
                [".", "WarningCount"]
              ]
              period = 300
              stat   = "Sum"
              region = "us-east-1"
              title  = "Application Error & Warning Count"
            }
          },
          {
            type = "metric"
            properties = {
              metrics = [
                ["CustomApp/API", "APIResponseTime"]
              ]
              period = 300
              stat   = "Average"
              region = "us-east-1"
              title  = "API Response Time"
            }
          },
          {
            type = "metric"
            properties = {
              metrics = [
                ["CustomApp/API", "API5xxCount"]
              ]
              period = 300
              stat   = "Sum"
              region = "us-east-1"
              title  = "API 5xx Error Count"
            }
          }
        ]
      }
    }
  }
}

output "log_group_names" {
  value = module.log_monitoring.log_group_names
}

output "alarm_arns" {
  value = module.log_monitoring.log_based_alarm_arns
}

