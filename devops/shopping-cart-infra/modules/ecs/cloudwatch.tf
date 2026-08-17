############################# ECS CLOUDWATCH #####################################

#================== CloudWatch Log Group ==================#
resource "aws_cloudwatch_log_group" "auth" {
  name              = "/ecs/${var.project.env}-${var.project.name}-auth"
  retention_in_days = 30

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-auth"
    Module = "${path.module}"
  })
}

resource "aws_cloudwatch_log_group" "product" {
  name              = "/ecs/${var.project.env}-${var.project.name}-product"
  retention_in_days = 30

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-product"
    Module = "${path.module}"
  })
}

resource "aws_cloudwatch_log_group" "cart" {
  name              = "/ecs/${var.project.env}-${var.project.name}-cart"
  retention_in_days = 30

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-cart"
    Module = "${path.module}"
  })
}