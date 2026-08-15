############################## ACM #############################

#================ ALB - Certificate =================#
resource "aws_acm_certificate" "alb" {
  domain_name       = "*.${var.project.env}-${var.project.name}.${var.project.domain}"
  validation_method = "DNS"
  region            = var.project.region

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-alb"
  })
}

#================ Create Validation Record =================#
resource "aws_route53_record" "alb_validation" {
  for_each = {
    for dvo in aws_acm_certificate.alb.domain_validation_options : dvo.domain_name => {
      name   = "${dvo.resource_record_name}"
      record = "${dvo.resource_record_value}"
      type   = "${dvo.resource_record_type}"
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.acm_hosted_zone_id
}

#================ Validate Certificate =================#
resource "aws_acm_certificate_validation" "alb" {
  certificate_arn         = aws_acm_certificate.alb.arn
  validation_record_fqdns = [for record in aws_route53_record.alb_validation : record.fqdn]
  region                  = var.project.region
}
