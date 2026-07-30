################################# EXAMPLE: Basic Alarms #######################################

# SNS Topic for notifications
resource "aws_sns_topic" "alerts" {
  name = "prod-cloudwatch-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"
}

# Custom CloudWatch Alarms
module "cloudwatch" {
  source = "../../"

  tags = {
    Name = "prod-custom-monitoring"
  }

  alarms = {
    # Lambda error rate alarm
    lambda_errors = {
      alarm_name          = "prod-lambda-high-errors"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "Errors"
      namespace           = "AWS/Lambda"
      period              = 300
      statistic           = "Sum"
      threshold           = 5
      alarm_description   = "Lambda function has more than 5 errors in 5 minutes"

      dimensions = {
        FunctionName = "my-lambda-function"
      }

      alarm_actions = [aws_sns_topic.alerts.arn]
      ok_actions    = [aws_sns_topic.alerts.arn]
    }

    # DynamoDB throttle alarm
    dynamodb_throttle = {
      alarm_name          = "prod-dynamodb-throttled"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 1
      metric_name         = "UserErrors"
      namespace           = "AWS/DynamoDB"
      period              = 60
      statistic           = "Sum"
      threshold           = 10
      alarm_description   = "DynamoDB table experiencing throttling"

      dimensions = {
        TableName = "my-table"
      }

      alarm_actions = [aws_sns_topic.alerts.arn]
    }

    # S3 bucket size alarm
    s3_bucket_size = {
      alarm_name          = "prod-s3-bucket-size-warning"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 1
      metric_name         = "BucketSizeBytes"
      namespace           = "AWS/S3"
      period              = 86400 # 1 day
      statistic           = "Average"
      threshold           = 107374182400 # 100 GB
      alarm_description   = "S3 bucket size exceeds 100GB"

      dimensions = {
        BucketName  = "my-bucket"
        StorageType = "StandardStorage"
      }

      alarm_actions = [aws_sns_topic.alerts.arn]
    }
  }
}

# Outputs
output "alarm_arns" {
  description = "ARNs of created alarms"
  value       = module.cloudwatch.alarm_arns
}

