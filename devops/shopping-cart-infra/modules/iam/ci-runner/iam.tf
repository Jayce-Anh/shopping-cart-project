############################ IAM ################################

resource "aws_iam_role" "ci_runner" {
  name = "${var.project.env}-${var.project.name}-${var.cicd_provider}-runner-provider"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.assume_role_statements
  })

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.cicd_provider}-runner-provider"
  })
}

resource "aws_iam_role_policy_attachment" "ci_runner_poweruser" {
  role       = aws_iam_role.ci_runner.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role_policy_attachment" "ci_runner_iam" {
  role       = aws_iam_role.ci_runner.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}
