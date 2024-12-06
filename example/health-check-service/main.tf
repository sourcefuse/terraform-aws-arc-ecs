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

module "health-check" {
  source = "../../modules/health-check"

  vpc_id      = "vpc-0e6c09980580ecbf6"
  environment = "develop"
  aws_region  = "us-east-1"

  ecs = {
    cluster_name         = "arc-ecs-module-poc"
    service_name         = "arc-ecs-module-service-poc"
    repository_name      = "884360309640.dkr.ecr.us-east-1.amazonaws.com/arc/arc-poc-ecs"
    enable_load_balancer = false
  }

  task = {
    container_port = 8100
  }

  alb = {
    name              = "arc-poc-alb"
    listener_port     = 8100
    security_group_id = ""
  }
}
