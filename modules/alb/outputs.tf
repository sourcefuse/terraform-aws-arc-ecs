################################################################################
## alb
################################################################################
output "alb_name" {
  description = "Name of the ALB"
  value       = module.alb.alb_name
}

output "alb_arn" {
  description = "ARN to the ALB"
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "External DNS name to the ALB"
  value       = module.alb.alb_dns_name
}
