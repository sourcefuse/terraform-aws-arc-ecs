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
  source = "../../"

  #####################
  ## ecs cluster
  #####################

  ecs_cluster = var.ecs_cluster
  capacity_provider = var.capacity_provider

  #####################
  ## ecs ec2 autoscaling
  #####################
  launch_template = var.launch_template
  asg = var.asg

  #####################
  ## ecs service
  #####################

  vpc_id      = var.vpc_id
  environment = var.environment
  ecs_service = var.ecs_service
  task = var.task
  lb = var.lb

  #####################
  ## ALB
  #####################

  cidr_blocks = var.cidr_blocks
  alb = var.alb
  alb_target_group = var.alb_target_group
  listener_rules = var.listener_rules
}
