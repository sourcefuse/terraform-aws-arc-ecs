locals {
  ## cluster
  cluster_name = var.cluster_name_override != null ? var.cluster_name_override : "${var.namespace}-${var.environment}-cluster"

  ## ssm
  ssm_params = [
    ## alb
    {
      name  = "/${var.namespace}/${var.environment}/alb/${module.alb.alb_name}/endpoint"
      value = module.alb.alb_dns_name
      type  = "String"
    },
    {
      name  = "/${var.namespace}/${var.environment}/alb/${module.alb.alb_name}/arn"
      value = module.alb.alb_arn
      type  = "String"
    },

    ## ecs
    {
      name  = "/${var.namespace}/${var.environment}/ecs/${module.ecs.cluster_name}/id"
      value = module.ecs.cluster_id
      type  = "String"
    },
    {
      name  = "/${var.namespace}/${var.environment}/ecs/${module.ecs.cluster_name}/arn"
      value = module.ecs.cluster_arn
      type  = "String"
    }
  ]
}
