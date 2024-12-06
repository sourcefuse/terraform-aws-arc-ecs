################################################################################
## defaults
################################################################################
terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

################################################################################
## ecs
################################################################################
module "ecs-cluster" {
  source = "../modules/ecs-cluster"

  create = true

  ecs_cluster = {
    cluster_name                     = "arc-ecs-module-poc"
    cluster_service_connect_defaults = []
    create_cloudwatch_log_group      = true
    cluster_service_connect_defaults = {}
    cluster_settings                 = []
    cluster_configuration = {
      execute_command_configuration = {
        logging = "OVERRIDE"
        log_configuration = {
          cloud_watch_log_group_name = "arc-poc-cluster-log-group"
        }
      }
    }

  }

  cloudwatch = {
    log_group_name              = "arc-poc-cluster-log-group"
    log_group_retention_in_days = 5
    log_group_tags              = { Environment = "poc" }
  }

  capacity_provider = {
    autoscaling_capacity_providers = {}
    fargate_capacity_providers = {
      fargate_cp = {
        name = "FARGATE"
        tags = {
          Environment = "poc"
        }
      }
    }
    default_capacity_provider_use_fargate = true
  }

  tags = {
    Project     = "arc-poc-ecs"
    Environment = "poc"
  }
}
