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
## ecs cluster
################################################################################

module "ecs" {
  source = "../modules/ecs"

  create = true

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
    autoscaling_capacity_providers = {}
    default_capacity_provider_use_fargate = true
    fargate_capacity_providers = {
      fargate_cp = {
        name = "FARGATE"
        tags = {
          Environment = "develop"
        }
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

  vpc_id = "vpc-12345"

  alb = {
    name     = "arc-poc-alb"
    internal = false
    port     = 80
  }

  alb_target_group = [{
    name     = "arc-poc-alb-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = "vpc-12345"
    health_check = {
      enabled = true
      path    = "/"
    }
  }]

  listener_rules = []
}


################################################################################
## health check service
################################################################################

module "health-check" {
  source = "../../modules/health-check"

  vpc_id      = "vpc-12345"
  environment = "develop"

  ecs = {
    cluster_name         = module.ecs.ecs_cluster.name 
    service_name         = "arc-ecs-module-service-poc"
    repository_name      = "12345.dkr.ecr.us-east-1.amazonaws.com/arc/arc-poc-ecs"
    enable_load_balancer = false
  }

  task = {
    container_port = 8100
  }

  alb = {
    name              = module.alb.name
    listener_port     = 8100
    security_group_id = ""
  }
  depends_on = [ module.alb ]
}
