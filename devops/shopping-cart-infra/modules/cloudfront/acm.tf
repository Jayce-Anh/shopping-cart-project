################################# CLOUDFRONT ACM CERTIFICATE #################################

resource "aws_acm_certificate" "cloudfront" {
  domain_name       = "${var.project.env}-${var.project.name}.${var.project.domain}"
  validation_method = "DNS"
  region            = "us-east-1"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.project.env}-${var.project.name}-cloudfront"
  })
}

#================ Create Validation Record =================#
resource "aws_route53_record" "cloudfront_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront.domain_validation_options : dvo.domain_name => {
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
  zone_id         = var.cf_hosted_zone_id
}

#================ Validate Certificate =================#
resource "aws_acm_certificate_validation" "cloudfront" {
  certificate_arn         = aws_acm_certificate.cloudfront.arn
  validation_record_fqdns = [for record in aws_route53_record.cloudfront_validation : record.fqdn]
  region                  = var.project.region
}