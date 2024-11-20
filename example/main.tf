################################################################################
## defaults
################################################################################
terraform {
  required_version = ">= 1.3, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
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
  project     = var.project_name

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
    cluster_name       = var.cluster_name
    service_name       = var.service_name
    service_name_short = var.service_name_short
    repository_name    = var.repository_name
  }

  task = {
    tasks_desired = var.tasks_desired_min

    container_port              = var.container_port
    container_health_check_path = var.container_health_check_path

    container_vcpu   = 1024
    container_memory = 2048

    environment_variables = {
      PORT                    = var.container_port
      URL_EXPIRE_SECONDS      = "3600"
    }

    container_definition = "container/container_definition.json.tftpl"
  }

  alb = {
    name                 = "service-alb-${var.environment}"
    listener_port        = var.alb_port
    deregistration_delay = var.deregistration_delay
  }

  autoscaling = {
    metric_name      = "CPUUtilization"
    minimum_capacity = var.tasks_desired_min
    maximum_capacity = var.tasks_desired_max

    dimensions = {
      ClusterName = local.cluster_name_full
      ServiceName = local.service_name_full
    }

    scale_up = {
      threshold = "85"
      cooldown  = "60"
      step_adjustment = [{
        metric_interval_lower_bound = 0
        scaling_adjustment          = 1
      }]
    }
    scale_down = {
      threshold = "20"
      cooldown  = "60"
      step_adjustment = [{
        metric_interval_lower_bound = 0
        scaling_adjustment          = -1
      }]
    }
  }

  tags = module.tags.tags
}
