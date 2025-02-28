################################################################################
## ECS cluster
################################################################################

module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  ecs_cluster = {
    name                        = var.ecs_cluster.name
    configuration               = var.ecs_cluster.configuration
    create_cloudwatch_log_group = var.ecs_cluster.create_cloudwatch_log_group
    service_connect_defaults    = var.ecs_cluster.service_connect_defaults
    settings                    = var.ecs_cluster.settings
  }

  capacity_provider = {
    autoscaling_capacity_providers = var.capacity_provider.autoscaling_capacity_providers
    use_fargate                    = var.capacity_provider.use_fargate
    fargate_capacity_providers     = var.capacity_provider.fargate_capacity_providers
  }
  launch_template = var.launch_template
  asg             = var.asg
  tags            = var.tags
}



################################################################################
##  ALB
################################################################################

module "alb" {
  count  = var.alb.create_alb ? 1 : 0
  source = "./modules/alb"

  vpc_id      = var.vpc_id
  cidr_blocks = var.cidr_blocks


  alb = {
    name                       = var.alb.name
    internal                   = var.alb.internal
    port                       = var.alb.port
    protocol                   = var.alb.protocol
    load_balancer_type         = var.alb.load_balancer_type
    idle_timeout               = var.alb.idle_timeout
    enable_deletion_protection = var.alb.enable_deletion_protection
    enable_http2               = var.alb.enable_http2
    certificate_arn            = var.alb.certificate_arn
    access_logs                = var.alb.access_logs
    # tags                       = var.tags
  }

  alb_target_group = [
    for tg in var.alb_target_group : {
      name                              = tg.name
      port                              = tg.port
      protocol                          = tg.protocol
      protocol_version                  = tg.protocol_version
      ip_address_type                   = tg.ip_address_type
      load_balancing_algorithm_type     = tg.load_balancing_algorithm_type
      load_balancing_cross_zone_enabled = tg.load_balancing_cross_zone_enabled
      deregistration_delay              = tg.deregistration_delay
      slow_start                        = tg.slow_start
      vpc_id                            = tg.vpc_id
      target_type                       = tg.target_type
      health_check = {
        enabled = tg.health_check.enabled
        path    = tg.health_check.path
      }
      stickiness = {
        enabled         = tg.stickiness.enabled
        type            = tg.stickiness.type
        cookie_duration = tg.stickiness.cookie_duration
      }
    }
  ]
  listener_rules = var.listener_rules
  tags           = var.tags
}


################################################################################
## ecs service
################################################################################

module "ecs_service" {
  count  = var.ecs_service.create_service ? 1 : 0
  source = "./modules/ecs-service"

  vpc_id      = var.vpc_id
  environment = var.environment

  ecs_service = {
    cluster_name             = module.ecs_cluster.ecs_cluster.name
    service_name             = var.ecs_service.service_name
    repository_name          = var.ecs_service.repository_name
    enable_load_balancer     = var.ecs_service.enable_load_balancer
    ecs_subnets              = var.ecs_service.ecs_subnets
    aws_lb_target_group_name = var.ecs_service.aws_lb_target_group_name
  }

  task = {
    tasks_desired               = var.task.tasks_desired
    launch_type                 = var.task.launch_type
    container_vcpu              = var.task.container_vcpu
    network_mode                = var.task.network_mode
    compatibilities             = var.task.compatibilities
    container_memory            = var.task.container_memory
    container_port              = var.task.container_port
    container_definition        = var.task.container_definition
    container_health_check_path = var.task.container_health_check_path
    environment_variables       = var.task.environment_variables
    task_execution_role         = var.task.task_execution_role
  }

  lb = {
    name                 = var.alb.name
    deregistration_delay = var.lb.deregistration_delay
    listener_port        = var.lb.listener_port
    security_group_id    = var.lb.security_group_id
  }
  tags       = var.tags
  depends_on = [module.alb]
}
