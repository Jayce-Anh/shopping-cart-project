######################## BASTION OUTPUT ###########################

output "sg_id" {
  value = aws_security_group.bastion.id
}

output "instance_id" {
  value = aws_instance.bastion.id
}

output "public_ip" {
  value = aws_eip.bastion.public_ip
}

output "private_ip" {
  value = aws_instance.bastion.private_ip
}

output "role_arn" {
  value       = aws_iam_role.bastion.arn
  description = "ARN of the bastion instance IAM role"
}

output "instance_arn" {
  value       = aws_instance.bastion.arn
  description = "ARN of the bastion instance"
}
