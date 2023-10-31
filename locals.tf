locals {
  ## cluster
  cluster_name = var.cluster_name_override != null ? var.cluster_name_override : "${var.namespace}-${var.environment}-cluster"

  ## ssm
  ssm_params = concat(var.additional_ssm_params, [
    # alb
    {
      name        = "/${var.namespace}/${var.environment}/alb/${module.alb.alb_name}/endpoint"
      value       = module.alb.alb_dns_name
      description = "ALB DNS Endpoint"
      type        = "String"
    },
    {
      name        = "/${var.namespace}/${var.environment}/alb/${module.alb.alb_name}/arn"
      value       = module.alb.alb_arn
      description = "ALB ARN"
      type        = "String"
    },
    {
      name        = "/${var.namespace}/${var.environment}/alb/${module.alb.alb_name}/dns_zone_id"
      value       = module.alb.alb_zone_id
      description = "ALB Zone ID"
      type        = "String"
    },
    {
      name        = "/${var.namespace}/${var.environment}/alb/${module.alb.alb_name}/health_check_fqdn"
      value       = length(module.health_check.route_53_fqdn) > 0 ? join(", ", module.health_check.route_53_fqdn) : "No health check FQDN"
      description = "ALB Health Check FQDN."
      type        = "String"
    },
    ## listeners
    {
      name        = "/${var.namespace}/${var.environment}/alb/${module.alb.alb_name}/http_listener/arn"
      value       = aws_lb_listener.http.arn
      description = "ARN of the HTTP listener"
      type        = "String"
    },
    {
      name        = "/${var.namespace}/${var.environment}/alb/${module.alb.alb_name}/https_listener/arn"
      value       = aws_lb_listener.https.arn
      description = "ARN of the HTTPS listener"
      type        = "String"
    },

    ## acm
    {
      name        = "/${var.namespace}/${var.environment}/alb/${module.alb.alb_name}/certificate_arn"
      value       = try(module.acm.arn, "Not Assigned")
      description = "ACM Certificate ARN."
      type        = "String"
    },

    ## ecs
    {
      name        = "/${var.namespace}/${var.environment}/ecs/${module.ecs.cluster_name}/cluster_name"
      value       = module.ecs.cluster_name
      description = "ECS Cluster Name"
      type        = "String"
    },
    {
      name        = "/${var.namespace}/${var.environment}/ecs/${module.ecs.cluster_name}/id"
      value       = module.ecs.cluster_id
      description = "ECS Cluster ID"
      type        = "String"
    },
    {
      name        = "/${var.namespace}/${var.environment}/ecs/${module.ecs.cluster_name}/arn"
      value       = module.ecs.cluster_arn
      description = "ECS Cluster ARN"
      type        = "String"
    }
  ])
}
