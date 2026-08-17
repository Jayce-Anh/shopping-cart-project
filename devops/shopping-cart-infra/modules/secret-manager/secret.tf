################################# SECRET MANAGER #################################

#================= Secrets =================#
# Gitlab runner token
resource "aws_secretsmanager_secret" "gitlab-runner" {
  name                    = "${var.project.env}-${var.project.name}-gitlab-runner-token"
  recovery_window_in_days = 0
  kms_key_id              = var.secret_kms_key
  description             = "GitLab token registered of GitLab runner"

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-gitlab-runner-token"
  })
}

# RDS credentials
resource "aws_secretsmanager_secret" "mysql" {
  name                    = "${var.project.env}-${var.project.name}-rds-credentials"
  recovery_window_in_days = 0
  kms_key_id              = var.secret_kms_key
  description             = "RDS credentials"

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-rds-credentials"
  })
}

# Helm git token
resource "aws_secretsmanager_secret" "helm-git-token" {
  name                    = "${var.project.env}-${var.project.name}-helm-git-token"
  recovery_window_in_days = 0
  kms_key_id              = var.secret_kms_key
  description             = "GitLab token for Helm repository"

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-helm-git-token"
  })
}

# Helm addon credentials
resource "aws_secretsmanager_secret" "helm-addon" {
  name                    = "${var.project.env}-${var.project.name}-helm-addon-credentials"
  recovery_window_in_days = 0
  kms_key_id              = var.secret_kms_key
  description             = "Password of Helm addons and slack webhook URL"

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-helm-addon-credentials"
  })
}

#================ Secret Version =================#
# Gitlab runner token
resource "aws_secretsmanager_secret_version" "gitlab-runner" {
  secret_id     = aws_secretsmanager_secret.gitlab-runner.id
  secret_string = "replace-me-with-gitlab-runner-token"

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# RDS credentials
resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.mysql.id
  secret_string = jsonencode(var.secret_rds)

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Helm git token
resource "aws_secretsmanager_secret_version" "helm-git-token" {
  secret_id     = aws_secretsmanager_secret.helm-git-token.id
  secret_string = "replace-me-with-gitlab-token"

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Helm addon passwords
resource "aws_secretsmanager_secret_version" "addons" {
  secret_id = aws_secretsmanager_secret.helm-addon.id
  secret_string = jsonencode({
    elastic_password  = "${random_password.addons["elastic"].result}"
    grafana_password  = "${random_password.addons["grafana"].result}"
    argocd_password   = "${random_password.addons["argocd"].result}"
    slack_webhook_url = "replace-me-with-slack-webhook-url"
  })
}

#================= Generate Random Passwords =================#
resource "random_password" "addons" {
  for_each = toset(["elastic", "grafana", "argocd"])
  length   = 16
  special  = true
}