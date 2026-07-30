################################# EXAMPLE: Custom Dashboard #######################################

module "cloudwatch_dashboard" {
  source = "../../"

  tags = {
    Name = "prod-application-dashboard"
  }

  dashboards = {
    application_overview = {
      dashboard_name = "prod-application-overview"
      dashboard_body = {
        widgets = [
          # Row 1: CPU Metrics
          {
            type   = "metric"
            x      = 0
            y      = 0
            width  = 12
            height = 6
            properties = {
              metrics = [
                ["AWS/ECS", "CPUUtilization", "ServiceName", "backend-service", { stat = "Average", label = "ECS Backend" }],
                ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "prod-db", { stat = "Average", label = "RDS Database" }],
                ["AWS/ElastiCache", "CPUUtilization", "CacheClusterId", "prod-redis", { stat = "Average", label = "Redis Cache" }]
              ]
              period = 300
              stat   = "Average"
              region = "us-east-1"
              title  = "CPU Utilization - All Services"
              yAxis = {
                left = {
                  min = 0
                  max = 100
                }
              }
            }
          },
          # Row 1: Memory Metrics
          {
            type   = "metric"
            x      = 12
            y      = 0
            width  = 12
            height = 6
            properties = {
              metrics = [
                ["AWS/ECS", "MemoryUtilization", "ServiceName", "backend-service"],
                ["AWS/ElastiCache", "DatabaseMemoryUsagePercentage", "CacheClusterId", "prod-redis"]
              ]
              period = 300
              stat   = "Average"
              region = "us-east-1"
              title  = "Memory Utilization"
              yAxis = {
                left = {
                  min = 0
                  max = 100
                }
              }
            }
          },
          # Row 2: ALB Metrics
          {
            type   = "metric"
            x      = 0
            y      = 6
            width  = 8
            height = 6
            properties = {
              metrics = [
                ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "app/prod-alb/xxxxx"],
              ]
              period = 300
              stat   = "Sum"
              region = "us-east-1"
              title  = "ALB Request Count"
            }
          },
          {
            type   = "metric"
            x      = 8
            y      = 6
            width  = 8
            height = 6
            properties = {
              metrics = [
                ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "app/prod-alb/xxxxx"],
              ]
              period = 300
              stat   = "Average"
              region = "us-east-1"
              title  = "ALB Response Time"
            }
          },
          {
            type   = "metric"
            x      = 16
            y      = 6
            width  = 8
            height = 6
            properties = {
              metrics = [
                ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", "app/prod-alb/xxxxx", { color = "#d62728", label = "5xx Errors" }],
                ["...", "HTTPCode_Target_4XX_Count", ".", ".", { color = "#ff7f0e", label = "4xx Errors" }]
              ]
              period = 300
              stat   = "Sum"
              region = "us-east-1"
              title  = "ALB Error Rates"
            }
          },
          # Row 3: Database Metrics
          {
            type   = "metric"
            x      = 0
            y      = 12
            width  = 12
            height = 6
            properties = {
              metrics = [
                ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "prod-db"]
              ]
              period = 300
              stat   = "Average"
              region = "us-east-1"
              title  = "RDS Database Connections"
            }
          },
          {
            type   = "metric"
            x      = 12
            y      = 12
            width  = 12
            height = 6
            properties = {
              metrics = [
                ["AWS/RDS", "ReadLatency", "DBInstanceIdentifier", "prod-db", { label = "Read Latency" }],
                [".", "WriteLatency", ".", ".", { label = "Write Latency" }]
              ]
              period = 300
              stat   = "Average"
              region = "us-east-1"
              title  = "RDS Latency"
            }
          },
          # Text widget
          {
            type   = "text"
            x      = 0
            y      = 18
            width  = 24
            height = 2
            properties = {
              markdown = "# Production Application Dashboard\n\nLast updated: ${timestamp()}\n\n**Services:** ECS, RDS, ElastiCache, ALB"
            }
          }
        ]
      }
    }
  }
}

output "dashboard_url" {
  description = "CloudWatch Dashboard URL"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=${module.cloudwatch_dashboard.dashboard_names["application_overview"]}"
}

