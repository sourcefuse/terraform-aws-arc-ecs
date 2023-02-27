locals {
  ## cluster
  cluster_name = var.cluster_name_override != null ? var.cluster_name_override : "${var.namespace}-${var.environment}-cluster"

  ## ssm
  #  ssm_params = concat(var.additional_ssm_params, [
  #    ## alb
  #    {
  #      name        = "/${var.namespace}/${var.environment}/alb/${module.alb.alb_name}/endpoint"
  #      value       = module.alb.alb_dns_name
  #      description = "ALB DNS Endpoint"
  #      type        = "String"
  #    },
  #    {
  #      name        = "/${var.namespace}/${var.environment}/alb/${module.alb.alb_name}/arn"
  #      value       = module.alb.alb_arn
  #      description = "ALB ARN"
  #      type        = "String"
  #    },
  #
  #    ## ecs
  #    {
  #      name        = "/${var.namespace}/${var.environment}/ecs/${module.ecs.cluster_name}/id"
  #      value       = module.ecs.cluster_id
  #      description = "ECS Cluster ID"
  #      type        = "String"
  #    },
  #    {
  #      name        = "/${var.namespace}/${var.environment}/ecs/${module.ecs.cluster_name}/arn"
  #      value       = module.ecs.cluster_arn
  #      description = "ECS Cluster ARN"
  #      type        = "String"
  #    }
  #  ])

  ## container definitions
  #  container_definitions = concat(var.container_definitions, [
  #    {
  #      name    = "${local.cluster_name}-health-check"
  #      image   = "ealen/echo-server"
  #      service = "health-check"
  #      #      memory    = 512
  #      #      cpu       = 100
  #      essential = true
  #
  #      port_mappings = [
  #        {
  #          containerPort = 80
  #          hostPort      = 80
  #        }
  #      ]
  #    }
  #  ])
}
