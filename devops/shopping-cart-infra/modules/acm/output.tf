############################# ACM OUTPUT ##############################

output "cert_arns" {
  description = "Validated ACM certificate ARNs"
  value = aws_acm_certificate.alb.arn
}

output "domain_names" {
  description = "ACM certificate domain names"
  value = aws_acm_certificate.alb.domain_name
}
