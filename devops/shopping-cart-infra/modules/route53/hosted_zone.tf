############################# ROUTE53 - HOSTED ZONE ##############################

resource "aws_route53_zone" "hosted_zone" {
  name          = var.r53_domain_name
  comment       = "Hosted zone for ${var.project.env}-${var.project.name}"
  force_destroy = true

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}"
  })
}
