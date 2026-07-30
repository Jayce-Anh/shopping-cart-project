################################### OUTPUTS ###########################

output "ec2_sg_id" {
  value = aws_security_group.ec2-sg.id
}

output "ec2_id" {
  value = aws_instance.ec2.id
}

output "public_ip" {
  value = aws_instance.ec2.public_ip
}

output "private_ip" {
  value = aws_instance.ec2.private_ip
}

output "ec2_role_arn" {
  value       = aws_iam_role.ec2_role.arn
  description = "ARN of the EC2 instance IAM role"
}

output "ec2_arn" {
  value       = aws_instance.ec2.arn
  description = "ARN of the EC2 instance"
}
