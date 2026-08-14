################################# SECRET MANAGER #################################

#================= Gitlab Runner Token =================#
resource "aws_secretsmanager_secret" "gitlab-runner" {
  name                    = "${var.project.env}-${var.project.name}-gitlab-runner-token"
  recovery_window_in_days = 0
  kms_key_id              = var.secret_kms_key
  description             = "GitLab token registered of GitLab runner"

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-gitlab-runner-token"
  })
}
