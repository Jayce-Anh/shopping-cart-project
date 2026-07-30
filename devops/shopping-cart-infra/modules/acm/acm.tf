############################## ACM ##############################

resource "aws_acm_certificate" "acm" {
  for_each = var.acm_certs

  domain_name               = each.value.domain
  validation_method         = "DNS"
  subject_alternative_names = coalesce(each.value.subject_alternative_names, [])

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-${each.key}"
  })
}
