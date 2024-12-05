################################################################################
## alb
################################################################################
/* output "alb_name" {
  description = "Name of the ALB"
  value       = module.alb.alb_name
}

output "alb_arn" {
  description = "ARN to the ALB"
  value       = aws_lb.this.alb_arn
}

output "alb_dns_name" {
  description = "External DNS name to the ALB"
  value       = aws_lb.this.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB"
  value       = aws_lb.this.alb_zone_id
} */


output "public_subnet_ids" {
  value = data.aws_subnets.public
  description = "List of IDs of the public subnets in the specified VPC"
}

output "alb_subnets_debug" {
  value = local.alb_subnets
}
