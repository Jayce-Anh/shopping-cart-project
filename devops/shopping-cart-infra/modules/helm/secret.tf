########################## HELM SECRETS ##########################

#================= Generate Random Passwords =================#
resource "random_password" "addons" {
  for_each = toset(["elastic", "grafana", "argocd"])
  length   = 16
  special  = true
}

#================= Helm Addon Credentials =================#
resource "aws_secretsmanager_secret" "helm-addon" {
  name                    = "${var.project.env}-${var.project.name}-helm-addon-credentials"
  recovery_window_in_days = 0
  kms_key_id              = var.helm_kms_key
  description             = "Password of Helm addons"

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-helm-addon-credentials"
  })
}

resource "aws_secretsmanager_secret_version" "addons" {
  secret_id = aws_secretsmanager_secret.helm-addon.id
  secret_string = jsonencode({
    elastic_password  = "${random_password.addons["elastic"].result}"
    grafana_password  = "${random_password.addons["grafana"].result}"
    argocd_password   = "${random_password.addons["argocd"].result}"
    slack_webhook_url = "replace-me-with-slack-webhook-url"
  })
}

#================= Helm Git Token =================#
resource "aws_secretsmanager_secret" "helm-git-token" {
  name                    = "${var.project.env}-${var.project.name}-helm-git-token"
  recovery_window_in_days = 0
  kms_key_id              = var.helm_kms_key
  description             = "GitLab token for Helm repository"

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-helm-git-token"
  })
}

resource "aws_secretsmanager_secret_version" "helm-git-token" {
  secret_id     = aws_secretsmanager_secret.helm-git-token.id
  secret_string = "replace-me-with-gitlab-token"

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Always read the latest token from Secrets Manager
data "aws_secretsmanager_secret_version" "helm_git_token" {
  secret_id = aws_secretsmanager_secret.helm-git-token.id
}
