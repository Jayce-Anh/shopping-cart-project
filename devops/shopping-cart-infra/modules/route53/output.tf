############################# ROUTE53 OUTPUT ##############################

output "hosted_zone_id" {
  value = aws_route53_zone.hosted_zone.id
}

output "hosted_zone_name" {
  value = aws_route53_zone.hosted_zone.name
}