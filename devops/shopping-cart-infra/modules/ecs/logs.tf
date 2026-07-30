resource "aws_cloudwatch_log_group" "be_log_group" {
  for_each          = var.task_definitions
  name              = "/ecs/${var.project.env}-${var.project.name}-${each.key}-log-group"
  retention_in_days = var.log_retention

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${each.key}-log-group"
  })
}