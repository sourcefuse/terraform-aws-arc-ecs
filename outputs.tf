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

output "alb_dns_zone_id" {
  description = "External DNS name to the ALB"
  value       = module.alb.alb_zone_id
}

output "health_check_fqdn" {
  description = "Health check FQDN record created in Route 53."
  value       = module.health_check.route_53_fqdn
}

output "alb_https_listener_arn" {
  value       = aws_lb_listener.https.arn
  description = "HTTPS listener ARN for downstream services to use"
}

output "alb_http_listener_arn" {
  value       = aws_lb_listener.http.arn
  description = "HTTP listener ARN for downstream services to use"
}

output "alb_security_group_id" {
  value       = module.alb_sg.id
  description = "ALB Security Group"
}

################################################################################
## acm
################################################################################
output "alb_certificate_arn" {
  description = "ACM Certificate ARN"
  value       = try(module.acm[0].arn, var.alb_certificate_arn)
}
