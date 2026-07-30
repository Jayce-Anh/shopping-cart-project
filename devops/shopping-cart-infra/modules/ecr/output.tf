######################## OUTPUT ############################
output "ecr_url" {
  value = aws_ecr_repository.ecr[sort(keys(var.ecr_services))[0]].repository_url
}

output "ecr_name" {
  value = aws_ecr_repository.ecr[sort(keys(var.ecr_services))[0]].name
}

output "ecr_urls" {
  value = { for k, v in aws_ecr_repository.ecr : k => v.repository_url }
}

output "ecr_repository_names" {
  value = { for k, v in aws_ecr_repository.ecr : k => v.name }
}
