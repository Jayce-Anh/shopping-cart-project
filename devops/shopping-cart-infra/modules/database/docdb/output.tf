##################################### Outputs #####################################

output "cluster_identifier" {
  description = "The DocumentDB cluster identifier"
  value       = aws_docdb_cluster.docdb_cluster.cluster_identifier
}

output "cluster_endpoint" {
  description = "The DocumentDB cluster endpoint"
  value       = aws_docdb_cluster.docdb_cluster.endpoint
}

output "cluster_reader_endpoint" {
  description = "The DocumentDB cluster reader endpoint"
  value       = aws_docdb_cluster.docdb_cluster.reader_endpoint
}

output "cluster_port" {
  description = "The DocumentDB cluster port"
  value       = aws_docdb_cluster.docdb_cluster.port
}

output "cluster_arn" {
  description = "The DocumentDB cluster ARN"
  value       = aws_docdb_cluster.docdb_cluster.arn
}

output "cluster_resource_id" {
  description = "The DocumentDB cluster resource ID"
  value       = aws_docdb_cluster.docdb_cluster.cluster_resource_id
}

output "cluster_hosted_zone_id" {
  description = "The Route53 hosted zone ID of the endpoint"
  value       = aws_docdb_cluster.docdb_cluster.hosted_zone_id
}

output "instance_endpoints" {
  description = "List of DocumentDB instance endpoints"
  value       = aws_docdb_cluster_instance.docdb_instances[*].endpoint
}

output "instance_identifiers" {
  description = "List of DocumentDB instance identifiers"
  value       = aws_docdb_cluster_instance.docdb_instances[*].identifier
}

output "security_group_id" {
  description = "The ID of the DocumentDB security group"
  value       = aws_security_group.sg_docdb.id
}

output "parameter_group_name" {
  description = "The name of the DocumentDB parameter group"
  value       = aws_docdb_cluster_parameter_group.docdb_parameter_group.name
}

output "subnet_group_name" {
  description = "The name of the DocumentDB subnet group"
  value       = aws_docdb_subnet_group.docdb_subnet_group.name
} 