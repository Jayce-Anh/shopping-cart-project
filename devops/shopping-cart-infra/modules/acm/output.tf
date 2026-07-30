######################### OUTPUTS #########################

output "cert_arns" {
  description = "ACM certificate ARNs keyed by use case"
  value = {
    for k, cert in aws_acm_certificate.acm : k => cert.arn
  }
}
