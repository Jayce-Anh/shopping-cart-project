resource "aws_wafv2_web_acl" "frontend_webacl" {
  provider = aws.east
  name     = "${var.project.env}-${var.project.name}-frontend-web-acl"
  scope    = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "FrontendWhiteListIP"
    priority = 2
    action {
      block {}
    }
    statement {
      not_statement {
        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.fe_white_list.arn
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "FrontendWhiteListIP"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "All"
    sampled_requests_enabled   = true
  }

  depends_on = [aws_wafv2_ip_set.fe_white_list]
  lifecycle {
    ignore_changes = [default_action, rule]
  }
}