################################################################################
## ecs cluster
################################################################################

module "ecs-cluster" {
  source = "../../modules/ecs-cluster"

  ecs_cluster = {
    name                        = var.ecs_cluster.name
    create_cloudwatch_log_group = var.ecs_cluster.create_cloudwatch_log_group
    service_connect_defaults    = var.ecs_cluster.service_connect_defaults
    settings                    = var.ecs_cluster.settings
  }

  capacity_provider = {
    autoscaling_capacity_providers        = var.capacity_provider.autoscaling_capacity_providers
    default_capacity_provider_use_fargate = var.capacity_provider.default_capacity_provider_use_fargate
  }
}


################################################################################
##  ALB
################################################################################

module "alb" {
  source = "../../modules/alb"

  vpc_id = var.vpc_id

  alb = {
    name     = var.alb.name
    internal = var.alb.internal
    port     = var.alb.port
  }

  alb_target_group = [{
    name        = var.alb_target_group.name
    port        = var.alb_target_group.port
    protocol    = var.alb_target_group.protocol
    vpc_id      = var.vpc_id
    target_type = var.alb_target_group.target_type
    health_check = {
      enabled = var.alb_target_group.health_check.enabled
      path    = var.alb_target_group.health_check.path
    }
  }]

  listener_rules = [{
    priority = var.listener_rules.priority
  }]
}


################################################################################
## ecs service
################################################################################

module "ecs-service" {
  source = "../../modules/ecs-service"

  vpc_id      = var.vpc_id
  environment = var.environment

  ecs = {
    cluster_name             = module.ecs-cluster.ecs_cluster.name
    service_name             = var.ecs.service_name
    repository_name          = var.ecs.repository_name
    enable_load_balancer     = var.ecs.enable_load_balancer
    aws_lb_target_group_name = var.ecs.aws_lb_target_group_name
  }

  task = {
    tasks_desired        = var.task.tasks_desired
    container_port       = var.task.container_port
    container_memory     = var.task.container_memory
    container_vcpu       = var.task.container_vcpu
    container_definition = var.task.container_definition
  }

  alb = {
    name              = module.alb.alb.name
    listener_port     = var.alb.listener_port
    security_group_id = module.alb.alb_security_group_id
  }
  depends_on = [module.alb]
}

