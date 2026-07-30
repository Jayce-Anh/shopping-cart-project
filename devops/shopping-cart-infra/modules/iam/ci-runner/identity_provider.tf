################################ IDENTITY PROVIDER ################################

data "tls_certificate" "ci_oidc" {
  url = local.ci.url
}

resource "aws_iam_openid_connect_provider" "ci_runner" {
  url             = data.tls_certificate.ci_oidc.url
  client_id_list  = local.ci.client_id
  thumbprint_list = [data.tls_certificate.ci_oidc.certificates[0].sha1_fingerprint]

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${var.cicd_provider}"
  })
}
