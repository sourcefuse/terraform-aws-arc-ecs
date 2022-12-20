################################################################################
## alb
################################################################################
output "alb_arn" {
  description = "ARN to the ALB"
  value       = module.alb.alb_arn
}

#output "target_group_arns" {
#  description = "Target group ARNs"
#  value = {
#    for k, v in aws_lb_target_group.this : k => v.arn
#  }
#}

output "alb_dns_name" {
  description = "External DNS name to the ALB"
  value       = module.alb.alb_dns_name
}
