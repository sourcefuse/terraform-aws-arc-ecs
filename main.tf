module "ecs" {
  source = "./modules/ecs-fargate"

  vpc_id               = var.vpc_id
  aws_region           = var.region
  environment          = var.environment
  project              = var.project
  proxy_security_group = data.aws_security_group.group.id

  ecs = {
    cluster_name    = var.ecs.cluster_name
    service_name    = var.ecs.service_name
    repository_name = var.ecs.repository_name
  }

  task = {
    tasks_desired = var.task.tasks_desired_min

    container_port = var.task.container_port

    container_vcpu   = var.task.container_vcpu
    container_memory = var.task.container_memory

    container_definition = var.task.container_definition
  }

  alb = {
    name                 = var.alb.name
    listener_port        = var.alb.alb_port
    deregistration_delay = var.alb.deregistration_delay
  }

  autoscaling = {
    metric_name      = var.autoscaling.metric_name
    minimum_capacity = var.autoscaling.minimum_capacity
    maximum_capacity = var.autoscaling.maximum_capacity

    scale_up = {
      threshold = var.autoscaling.scale_up.threshold
      cooldown  = var.autoscaling.scale_up.cooldown
      step_adjustment = [{
        metric_interval_lower_bound = var.autoscaling.scale_up.step_adjustment
        scaling_adjustment          = var.autoscaling.scale_up.step_adjustment
      }]
    }
    scale_down = {
      threshold = var.scale_down.threshold
      cooldown  = var.scale_down.cooldown
      step_adjustment = [{
        metric_interval_lower_bound = var.autoscaling.scale_down.step_adjustment
        scaling_adjustment          = var.autoscaling.scale_down.step_adjustment
      }]
    }
  }
}
