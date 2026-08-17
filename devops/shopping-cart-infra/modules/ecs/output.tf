######################## ECS OUTPUT ########################

output "cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.ecs_cluster.id
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_tasks_sg_id" {
  description = "Security group ID for ECS tasks"
  value       = aws_security_group.ecs_tasks.id
}

output "service_names" {
  description = "ECS service names by key"
  value = {
    auth    = "${aws_ecs_service.auth.name}"
    product = "${aws_ecs_service.product.name}"
    cart    = "${aws_ecs_service.cart.name}"
  }
}

output "task_definition_arns" {
  description = "ECS task definition ARNs by key"
  value = {
    auth    = "${aws_ecs_task_definition.auth.arn}"
    product = "${aws_ecs_task_definition.product.arn}"
    cart    = "${aws_ecs_task_definition.cart.arn}"
  }
}

output "container_names" {
  description = "Container name from each ECS task definition (must match artifact.json)"
  value = {
    auth    = "${jsondecode(aws_ecs_task_definition.auth.container_definitions)[0].name}"
    product = "${jsondecode(aws_ecs_task_definition.product.container_definitions)[0].name}"
    cart    = "${jsondecode(aws_ecs_task_definition.cart.container_definitions)[0].name}"
  }
}
