################################################################################
## cluster
################################################################################
output "cluster_arn" {
  value = module.ecs.cluster_arn
}

output "cluster_id" {
  value = module.ecs.cluster_id
}

output "cluster_name" {
  value = module.ecs.cluster_name
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
