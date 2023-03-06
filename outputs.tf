################################################################################
## cluster
################################################################################
output "cluster_arn" {
  description = "ECS Cluster ARN"
  value       = module.ecs.cluster_arn
}

output "cluster_id" {
  description = "ECS Cluster ID"
  value       = module.ecs.cluster_id
}

output "cluster_name" {
  description = "ECS Cluster name"
  value       = module.ecs.cluster_name
}

################################################################################
## alb
################################################################################
output "alb_arn" {
  description = "ARN to the ALB"
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "External DNS name to the ALB"
  value       = module.alb.alb_dns_name
}

################################################################################
## acm
################################################################################
output "alb_certificate_arn" {
  description = "ACM Certificate ARN"
  value       = try(module.acm[0].arn, var.alb_certificate_arn)
}
