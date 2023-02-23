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
