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

output "alb" {
  value = {
    name = aws_lb.this.name
  }
}

# Use the filtered subnets
output "public_subnets" {
  value = local.public_subnets
}

output "alb_security_group_id" {
  value = aws_security_group.lb_sg.id
}
