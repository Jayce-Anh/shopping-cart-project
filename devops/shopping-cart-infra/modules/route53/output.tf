output "hosted_zone_id" {
  description = "Route53 hosted zone ID"
  value       = aws_route53_zone.hosted_zone.zone_id
}

output "hosted_zone_arn" {
  description = "Route53 hosted zone ARN"
  value       = aws_route53_zone.hosted_zone.arn
}

output "hosted_zone_name" {
  description = "Route53 hosted zone name"
  value       = aws_route53_zone.hosted_zone.name
}

output "name_servers" {
  description = "Delegation name servers — set these at your domain registrar"
  value       = aws_route53_zone.hosted_zone.name_servers
}

output "ns_records" {
  description = "NS delegation records to configure at your domain registrar"
  value = [
    for ns in aws_route53_zone.hosted_zone.name_servers : {
      type  = "NS"
      name  = aws_route53_zone.hosted_zone.name
      value = ns
    }
  ]
}

output "registrar_name_servers" {
  description = "Name servers formatted for copy-paste into registrar settings"
  value       = join("\n", aws_route53_zone.hosted_zone.name_servers)
}
