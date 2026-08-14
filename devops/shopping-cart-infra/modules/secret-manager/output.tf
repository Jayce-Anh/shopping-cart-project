############################## SECRET MANAGER OUTPUT ##############################

output "secret_id" {
  value = {
    gitlab-runner-token = "${aws_secretsmanager_secret.gitlab-runner.id}"
  }
  description = "Map of secret IDs"
}

output "secret_arn" {
  value = {
    gitlab-runner-token = "${aws_secretsmanager_secret.gitlab-runner.arn}"
  }
  description = "Map of secret ARNs"
}
