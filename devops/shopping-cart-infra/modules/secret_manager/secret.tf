################################# SECRET MANAGER #################################

# Create secret manager
resource "aws_secretsmanager_secret" "secret" {
  for_each = var.secrets

  name                    = "${var.project.env}-${var.project.name}-${each.value.secret_name}"
  recovery_window_in_days = each.value.recovery_window_in_days
  kms_key_id              = var.kms_key_arn
  description             = each.value.description

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${each.value.secret_name}"
  })
}

# Create secret manager with managed value (JSON map or plain string)
resource "aws_secretsmanager_secret_version" "secret_managed" {
  for_each = {
    for k, v in var.secrets : k => v
    if !v.use_initial_value || v.secret_string != null
  }

  secret_id = aws_secretsmanager_secret.secret[each.key].id
  secret_string = coalesce(
    each.value.secret_string,
    jsonencode(each.value.secret_data),
  )
}