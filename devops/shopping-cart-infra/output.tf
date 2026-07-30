######################## OUTPUT #######################

#============== EKS ==================#
output "eks_name" {
  description = "EKS name servers — set these at your domain registrar"
  value       = module.eks.eks_cluster_name
}

#============== RDS ================#
output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.rds_endpoint
}

#============== Runner Role ================#
output "runner_role_arn" {
  description = "Runner role ARN"
  value       = module.runner_role.runner_role_arn
}

#============== Valkey ================#
output "cache_primary_endpoint" {
  description = "Primary endpoint of the cache"
  value       = module.valkey.cache_primary_endpoint
}

#============== Route 53 ==================#
output "route53_ns_records" {
  description = "Route53 NS delegation records"
  value       = module.route53.ns_records
}

output "route53_registrar_name_servers" {
  description = "Route53 name servers formatted for copy-paste into registrar settings"
  value       = module.route53.registrar_name_servers
}

#============== ALB ==================#
output "alb_dns_name" {
  description = "External ALB DNS name (point platform hostnames here manually in Route53)"
  value       = module.alb.lb_dns_name
}

output "alb_tg_arns" {
  description = "Target group ARNs for TargetGroupBinding in manifest repo"
  value       = module.alb.tg_arns
}

#============== EKS Public ALB (deprecated) ==================#
output "eks_public_alb_sg_id" {
  description = "Deprecated: shared EKS public ALB SG (disabled; platform tools use external ALB)"
  value       = module.eks.public_alb_sg_id
}