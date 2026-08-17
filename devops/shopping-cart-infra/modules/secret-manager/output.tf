############################## SECRET MANAGER OUTPUT ##############################

output "secret_id" {
  value = {
    gitlab-runner-token    = "${aws_secretsmanager_secret.gitlab-runner.id}"
    rds-credentials        = "${aws_secretsmanager_secret.mysql.id}"
    helm-git-token         = "${aws_secretsmanager_secret.helm-git-token.id}"
    helm-addon-credentials = "${aws_secretsmanager_secret.helm-addon.id}"
  }
  description = "Map of secret IDs"
}

output "secret_arn" {
  value = {
    gitlab-runner-token    = "${aws_secretsmanager_secret.gitlab-runner.arn}"
    rds-credentials        = "${aws_secretsmanager_secret.mysql.arn}"
    helm-git-token         = "${aws_secretsmanager_secret.helm-git-token.arn}"
    helm-addon-credentials = "${aws_secretsmanager_secret.helm-addon.arn}"
  }
  description = "Map of secret ARNs"
}
