################################ CI/CD PROVIDER ################################

locals {
  ci_providers = {
    gitlab = {
      url         = "https://gitlab.com"
      host        = "gitlab.com"
      audience    = "https://gitlab.com"
      client_id   = ["https://gitlab.com"]
      sub_pattern = "project_path:${var.runner_project_path}${var.runner_project_scope}"
    }
    github = {
      url         = "https://token.actions.githubusercontent.com"
      host        = "token.actions.githubusercontent.com"
      audience    = "sts.amazonaws.com"
      client_id   = ["sts.amazonaws.com"]
      sub_pattern = "repo:${var.runner_project_path}${var.runner_project_scope}"
    }
  }
  # Trust identity provider
  ci = local.ci_providers[var.cicd_provider]

  oidc_trust_statement = {
    Effect = "Allow"
    Principal = {
      Federated = "${aws_iam_openid_connect_provider.ci_runner.arn}"
    }
    Action = "sts:AssumeRoleWithWebIdentity"
    Condition = {
      StringEquals = {
        "${local.ci.host}:aud" = ["${local.ci.audience}"]
      }
      StringLike = {
        "${local.ci.host}:sub" = ["${local.ci.sub_pattern}"]
      }
    }
  }

  ec2_trust_statement = {
    Effect = "Allow"
    Principal = {
      AWS = var.runner_ec2_role_arn
    }
    Action = "sts:AssumeRole"
  }

  assume_role_statements = [
    local.oidc_trust_statement,
    local.ec2_trust_statement,
  ]
}
