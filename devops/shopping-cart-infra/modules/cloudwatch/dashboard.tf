################################# CLOUDWATCH DASHBOARDS #######################################
resource "aws_cloudwatch_dashboard" "this" {
  for_each = var.cw_dashboard

  dashboard_name = each.value.dashboard_name
  dashboard_body = jsonencode(each.value.dashboard_body)
}