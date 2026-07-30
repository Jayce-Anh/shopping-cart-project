output "parameter_name" {
  value = { for k, v in aws_ssm_parameter.parameter : k => v.name }
}
