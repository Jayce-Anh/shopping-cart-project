################################ PARAMETER STORE ################################

resource "aws_ssm_parameter" "parameter" {
  for_each = toset(var.source_services)
  name     = "/${var.project.env}/${var.project.name}/${each.key}/env"
  type     = "SecureString"
  value    = "env"
  tier     = "Advanced"
  tags = {
    environment = "${var.project.env}"
  }
  lifecycle {
    ignore_changes = [value]
  }
}






