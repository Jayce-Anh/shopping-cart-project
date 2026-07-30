# CloudWatch Module

A flexible Terraform module for creating custom CloudWatch monitoring resources including alarms, dashboards, log groups, and metric filters.

## Features

- ✅ **CloudWatch Metric Alarms** - Monitor any AWS metric
- ✅ **Composite Alarms** - Combine multiple alarms with logic (AND/OR)
- ✅ **CloudWatch Dashboards** - Custom visualization dashboards
- ✅ **Log Groups** - Centralized logging with retention policies
- ✅ **Log Metric Filters** - Extract metrics from logs
- ✅ **Log-based Alarms** - Alert on log patterns

## Usage

### Basic Alarm

```hcl
module "custom_monitoring" {
  source = "../../modules/cloudwatch"
  
  tags = {
    Name = "prod-custom-monitoring"
  }
  
  alarms = {
    high_error_rate = {
      alarm_name          = "prod-high-error-rate"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "Errors"
      namespace           = "AWS/Lambda"
      period              = 300
      statistic           = "Sum"
      threshold           = 10
      alarm_description   = "Alert when Lambda errors exceed 10"
      
      dimensions = {
        FunctionName = "my-lambda-function"
      }
      
      alarm_actions = [aws_sns_topic.alerts.arn]
    }
  }
}
```

### Cross-Service Dashboard

```hcl
module "monitoring_dashboard" {
  source = "../../modules/cloudwatch"
  
  tags = {
    Name = "prod-overview-dashboard"
  }
  
  dashboards = {
    overview = {
      dashboard_name = "prod-application-overview"
      dashboard_body = {
        widgets = [
          {
            type = "metric"
            properties = {
              metrics = [
                ["AWS/ECS", "CPUUtilization", "ServiceName", "my-service"],
                ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "my-db"],
                ["AWS/ElastiCache", "CPUUtilization", "CacheClusterId", "my-redis"]
              ]
              period = 300
              stat   = "Average"
              region = "us-east-1"
              title  = "CPU Utilization Across Services"
            }
          }
        ]
      }
    }
  }
}
```

### Log-based Monitoring

```hcl
module "log_monitoring" {
  source = "../../modules/cloudwatch"
  
  tags = {
    Name = "prod-log-monitoring"
  }
  
  # Create log group
  log_groups = {
    app_logs = {
      name              = "/aws/application/prod"
      retention_in_days = 30
    }
  }
  
  # Extract metrics from logs
  log_metric_filters = {
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
  }
  
  # Alarm on log metrics
  log_based_alarms = {
    high_error_count = {
      alarm_name          = "prod-high-error-count"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 1
      metric_name         = "ErrorCount"
      namespace           = "CustomApp/Logs"
      period              = 300
      statistic           = "Sum"
      threshold           = 5
      alarm_description   = "More than 5 errors in 5 minutes"
      
      alarm_actions = [aws_sns_topic.alerts.arn]
    }
  }
}
```

### Composite Alarm (Multiple Conditions)

```hcl
module "composite_monitoring" {
  source = "../../modules/cloudwatch"
  
  tags = {
    Name = "prod-composite-alarms"
  }
  
  # Individual alarms
  alarms = {
    cpu_high = {
      alarm_name          = "prod-cpu-high"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 300
      statistic           = "Average"
      threshold           = 80
      
      dimensions = {
        InstanceId = "i-1234567890"
      }
    }
    
    memory_high = {
      alarm_name          = "prod-memory-high"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "MemoryUtilization"
      namespace           = "CWAgent"
      period              = 300
      statistic           = "Average"
      threshold           = 80
      
      dimensions = {
        InstanceId = "i-1234567890"
      }
    }
  }
  
  # Composite alarm (triggers when BOTH are in alarm state)
  composite_alarms = {
    resource_pressure = {
      alarm_name        = "prod-resource-pressure"
      alarm_description = "Both CPU and Memory are high"
      alarm_rule        = "ALARM(prod-cpu-high) AND ALARM(prod-memory-high)"
      
      alarm_actions = [aws_sns_topic.critical_alerts.arn]
    }
  }
}
```

## Complete Example

See [`examples/`](./examples/) directory for complete working examples:

- [Basic Alarms](./examples/basic-alarms/)
- [Custom Dashboard](./examples/custom-dashboard/)
- [Log Monitoring](./examples/log-monitoring/)
- [Multi-Service Monitoring](./examples/multi-service/)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| tags | Common tags to apply to all resources | `object({ Name = string })` | n/a | yes |
| alarms | Map of CloudWatch metric alarms | `map(object)` | `{}` | no |
| composite_alarms | Map of CloudWatch composite alarms | `map(object)` | `{}` | no |
| dashboards | Map of CloudWatch dashboards | `map(object)` | `{}` | no |
| log_groups | Map of CloudWatch log groups | `map(object)` | `{}` | no |
| log_metric_filters | Map of CloudWatch log metric filters | `map(object)` | `{}` | no |
| log_based_alarms | Map of alarms based on log metrics | `map(object)` | `{}` | no |
| default_log_retention | Default log retention in days | `number` | `14` | no |

## Outputs

| Name | Description |
|------|-------------|
| alarm_arns | ARNs of created CloudWatch alarms |
| alarm_ids | IDs of created CloudWatch alarms |
| composite_alarm_arns | ARNs of created composite alarms |
| dashboard_arns | ARNs of created dashboards |
| dashboard_names | Names of created dashboards |
| log_group_arns | ARNs of created log groups |
| log_group_names | Names of created log groups |
| log_metric_filter_ids | IDs of created log metric filters |
| log_based_alarm_arns | ARNs of log-based alarms |

## Common Alarm Operators

| Operator | Description |
|----------|-------------|
| `GreaterThanThreshold` | Value > threshold |
| `GreaterThanOrEqualToThreshold` | Value >= threshold |
| `LessThanThreshold` | Value < threshold |
| `LessThanOrEqualToThreshold` | Value <= threshold |

## Common Statistics

| Statistic | Description |
|-----------|-------------|
| `Average` | Average value |
| `Sum` | Sum of all values |
| `Minimum` | Minimum value |
| `Maximum` | Maximum value |
| `SampleCount` | Number of data points |

## Common AWS Namespaces

| Namespace | Service |
|-----------|---------|
| `AWS/EC2` | EC2 Instances |
| `AWS/ECS` | ECS Services |
| `AWS/RDS` | RDS Databases |
| `AWS/ElastiCache` | ElastiCache (Redis/Memcached) |
| `AWS/Lambda` | Lambda Functions |
| `AWS/ApplicationELB` | Application Load Balancers |
| `AWS/NetworkELB` | Network Load Balancers |
| `AWS/S3` | S3 Buckets |
| `AWS/DynamoDB` | DynamoDB Tables |
| `AWS/SQS` | SQS Queues |
| `AWS/SNS` | SNS Topics |

## Tips

### 1. Use Composite Alarms for Complex Logic

Instead of getting multiple alerts, combine conditions:
```hcl
alarm_rule = "ALARM(alarm1) AND ALARM(alarm2) OR ALARM(alarm3)"
```

### 2. Set Appropriate Evaluation Periods

- Single period: Immediate alerts (may be noisy)
- Multiple periods: More reliable, reduces false positives

### 3. Use Datapoints to Alarm

Require multiple breaches within evaluation window:
```hcl
evaluation_periods  = 3
datapoints_to_alarm = 2  # Alarm after 2 out of 3 breaches
```

### 4. Treat Missing Data Wisely

- `notBreaching` - Ignore missing data (default)
- `breaching` - Treat missing data as bad
- `ignore` - Maintain alarm state
- `missing` - Transition to INSUFFICIENT_DATA

## Cost Optimization

1. **Consolidate Dashboards** - First 3 are free
2. **Use Composite Alarms** - Reduce total alarm count
3. **Adjust Log Retention** - Shorter retention = lower costs
4. **Filter Before Logging** - Don't log unnecessary data

## License

MIT

