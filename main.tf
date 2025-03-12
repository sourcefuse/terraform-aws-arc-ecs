################################################################################
## ECS cluster
################################################################################

module "ecs_cluster" {
  source = "./modules/ecs-cluster"
  count  = var.ecs_cluster.create ? 1 : 0
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
## ecs service
################################################################################

module "ecs_service" {
  count  = var.ecs_service.create ? 1 : 0
  source = "./modules/ecs-service"

  vpc_id           = var.vpc_id
  environment      = var.environment
  target_group_arn = var.target_group_arn

  ecs_service = {
    cluster_name             = var.ecs_cluster_name
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
    deregistration_delay = var.lb_data.deregistration_delay
    listener_port        = var.lb_data.listener_port
    security_group_id    = var.lb_data.security_group_id
  }
  tags = var.tags
}
