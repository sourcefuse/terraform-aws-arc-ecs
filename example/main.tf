################################################################################
## defaults
################################################################################
terraform {
  required_version = ">= 1.4, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0, < 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.3"

  environment = var.environment
  project     = var.project

  extra_tags = {
    Example  = "True"
    RepoPath = "https://github.com/sourcefuse/terraform-aws-arc-dms"
  }
}

################################################################################
## ecs
################################################################################
module "ecs" {
  source = "../modules/ecs-fargate"

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
    tasks_desired        = var.task.tasks_desired
    container_vcpu       = var.task.container_vcpu
    container_memory     = var.task.container_memory
    container_port       = var.task.container_port
    container_definition = var.task.container_definition

    environment_variables = {
      PORT = var.task.container_port
    }
  }

  alb = {
    name                 = var.alb.name
    listener_port        = var.alb.alb_port
    deregistration_delay = var.alb.deregistration_delay
  }

  autoscaling = {
    metric_name      = var.autosclaing.metric_name
    minimum_capacity = var.autosclaing.tasks_desired_min
    maximum_capacity = var.autosclaing.tasks_desired_min

    dimensions = {
      ClusterName = local.cluster_name_full
      ServiceName = local.service_name_full
    }

    scale_up = {
      threshold = var.autoscaling.scale_up.threshold
      cooldown  = var.autoscaling.scale_up.cooldown
      step_adjustment = [{
        metric_interval_lower_bound = var.autoscaling.scale_up.step_adjustment.metric_interval_lower_bound
        scaling_adjustment          = var.autoscaling.scale_up.step_adjustment.scaling_adjustment
      }]
    }
    scale_down = {
      threshold = var.autoscaling.scale_down.threshold
      cooldown  = var.autoscaling.scale_down.cooldown
      step_adjustment = [{
        metric_interval_lower_bound = var.autoscaling.scale_down.step_adjustment.metric_interval_lower_bound
        scaling_adjustment          = var.autoscaling.scale_down.step_adjustment.scaling_adjustment
      }]
    }
  }
}
