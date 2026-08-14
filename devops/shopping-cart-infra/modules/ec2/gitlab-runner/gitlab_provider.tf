################################ GITLAB OIDC IDENTITY PROVIDER ################################

data "tls_certificate" "gitlab" {
  url = "https://gitlab.com"
}

resource "aws_iam_openid_connect_provider" "gitlab" {
  url             = data.tls_certificate.gitlab.url
  client_id_list  = ["https://gitlab.com"]
  thumbprint_list = [data.tls_certificate.gitlab.certificates[0].sha1_fingerprint]

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-gitlab"
  })
}
