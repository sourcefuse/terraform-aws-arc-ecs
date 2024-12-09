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


module "ecs_cluster" {
  source = "../"

  #####################
  ## ecs cluster
  #####################

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
    use_fargate                    = true
    fargate_capacity_providers = {
      fargate_cp = {
        name = "FARGATE"
      }
    }
  }

  #####################
  ## ecs service
  #####################

  vpc_id      = "vpc-12345"
  environment = "develop"

  ecs_service = {
    cluster_name             = "arc-ecs-module-poc"
    service_name             = "arc-ecs-module-service-poc"
    repository_name          = "12345.dkr.ecr.us-east-1.amazonaws.com/arc/arc-poc-ecs"
    enable_load_balancer     = false
    aws_lb_target_group_name = "arc-poc-alb-tg"
    create_service           = false
  }

  task = {
    tasks_desired        = 1
    container_port       = 80
    container_memory     = 1024
    container_vcpu       = 256
    container_definition = "container/container_definition.json.tftpl"
  }

  lb = {
    name              = "arc-poc-alb"
    listener_port     = 80
    security_group_id = "sg-12345"
  }

  #####################
  ## ALB
  #####################

  cidr_blocks = null

  alb = {
    name       = "arc-poc-alb"
    internal   = false
    port       = 80
    create_alb = false
  }

  alb_target_group = [{
    name        = "arc-poc-alb-tg"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = "vpc-12345"
    target_type = "ip"
    health_check = {
      enabled = true
      path    = "/"
    }
    stickiness = {
      enabled = true
      type    = "lb_cookie"
    }
  }]

  listener_rules = []
}
