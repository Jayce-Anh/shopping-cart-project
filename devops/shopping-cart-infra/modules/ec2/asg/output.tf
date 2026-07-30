################################### OUTPUTS ###########################

output "asg_sg_id" {
  value = aws_security_group.asg_sg.id
}

output "asg_id" {
  value       = aws_autoscaling_group.asg.id
  description = "Auto Scaling Group ID"
}

output "asg_name" {
  value       = aws_autoscaling_group.asg.name
  description = "Auto Scaling Group name"
}

output "asg_arn" {
  value       = aws_autoscaling_group.asg.arn
  description = "Auto Scaling Group ARN"
}

output "asg_desired_capacity" {
  value       = aws_autoscaling_group.asg.desired_capacity
  description = "Desired capacity of the Auto Scaling Group"
}

output "asg_min_size" {
  value       = aws_autoscaling_group.asg.min_size
  description = "Minimum size of the Auto Scaling Group"
}

output "asg_max_size" {
  value       = aws_autoscaling_group.asg.max_size
  description = "Maximum size of the Auto Scaling Group"
}

output "launch_template_id" {
  value       = aws_launch_template.launch_template.id
  description = "Launch Template ID"
}

output "launch_template_latest_version" {
  value       = aws_launch_template.launch_template.latest_version
  description = "Latest version of the Launch Template"
}

output "ec2_role_arn" {
  value       = aws_iam_role.ec2_role.arn
  description = "ARN of the instance IAM role"
}
