########################### OUTPUTS #######################################

output "cluster_arn" {
  description = "ARN that identifies the cluster"
  value       = aws_ecs_cluster.ecs_cluster.arn
}

output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = aws_ecs_cluster.ecs_cluster.id
}

output "cluster_name" {
  description = "Name that identifies the cluster"
  value       = aws_ecs_cluster.ecs_cluster.name
}

output "cloudwatch_log_group_name" {
  description = "Name of CloudWatch log group created"
  value       = { for k, v in aws_cloudwatch_log_group.be_log_group : k => v.name }
}

output "cloudwatch_log_group_arn" {
  description = "ARN of CloudWatch log group created"
  value       = { for k, v in aws_cloudwatch_log_group.be_log_group : k => v.arn }
}

output "task_exec_iam_role_name" {
  description = "Task execution IAM role name"
  value       = aws_iam_role.ecsTaskExecutionRole.name
}

output "ecs_tasks_sg_id" {
  description = "ECS task security group"
  value       = aws_security_group.ecs_tasks.id
}

output "ecs_tasks_without_ALB_sg_id" {
  description = "ECS task security group"
  value       = aws_security_group.ecs_tasks_without_ALB.id
}

output "service_name" {
  description = "Map of ECS service names"
  value       = { for k, v in aws_ecs_service.service : k => v.name }
}