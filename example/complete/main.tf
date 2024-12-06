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

provider "aws" {
  region = "us-east-1"
}

################################################################################
## ecs cluster
################################################################################

module "ecs-cluster" {
  source = "../../modules/ecs-cluster"

  ecs_cluster = {
    name = "arc-ecs-module-poc"
    configuration = {
      execute_command_configuration = {
        logging = "OVERRIDE"
        log_configuration = {
          log_group_name = "arc-poc-cluster-log-group"
        }
      }
    }
    create_cloudwatch_log_group = true
    service_connect_defaults    = {}
    settings                    = []
  }

  capacity_provider = {
    autoscaling_capacity_providers        = {}
    default_capacity_provider_use_fargate = true
    fargate_capacity_providers = {
      fargate_cp = {
        name = "FARGATE"
      }
    }
  }
  tags = {
    Project     = "arc-poc-ecs"
    Environment = "develop"
  }
}


################################################################################
##  ALB
################################################################################

module "alb" {
  source = "../../modules/alb"

  vpc_id = "vpc-123445"

  alb = {
    name     = "arc-poc-alb"
    internal = false
    port     = 80
  }

  alb_target_group = [{
    name        = "arc-poc-alb-tg"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = "vpc-123445"
    target_type = "ip"
    health_check = {
      enabled = true
      path    = "/"
    }
  }]

  listener_rules = []
}


################################################################################
## ecs service
################################################################################

module "ecs-service" {
  source = "../../modules/ecs-service"

  vpc_id      = "vpc-123445"
  environment = "develop"

  ecs = {
    cluster_name             = module.ecs-cluster.ecs_cluster.name
    service_name             = "arc-ecs-module-service-poc"
    repository_name          = "23112.dkr.ecr.us-east-1.amazonaws.com/arc/arc-poc-ecs"
    enable_load_balancer     = false
    aws_lb_target_group_name = "arc-poc-alb-tg"
  }

  task = {
    tasks_desired        = 1
    container_port       = 8100
    container_memory     = 1024
    container_vcpu       = 256
    container_definition = "container/container_definition.json.tftpl"
  }

  alb = {
    name              = module.alb.alb.name
    listener_port     = 8100
    security_group_id = module.alb.alb_security_group_id
  }
  depends_on = [module.alb]
}
