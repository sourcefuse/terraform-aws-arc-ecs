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

module "ecs-service" {
  source = "../../modules/ecs-service"

  vpc_id      = "vpc-12345"
  environment = "develop"

  ecs = {
    cluster_name         = "arc-ecs-module-poc"
    service_name         = "arc-ecs-module-service-poc"
    repository_name      = "12345.dkr.ecr.us-east-1.amazonaws.com/arc/arc-poc-ecs"
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
