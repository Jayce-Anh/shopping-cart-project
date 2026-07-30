##################################### ROUTE53 HOSTED ZONE #####################################

resource "aws_route53_zone" "hosted_zone" {
  name          = var.route53_domain_name
  comment       = coalesce(var.route53_comment, "Hosted zone for ${var.project.env}-${var.project.name}")
  force_destroy = var.route53_hosted_zone_force_del

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}"
  })
}
