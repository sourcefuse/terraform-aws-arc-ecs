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
  region = var.region
}

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.6"

  environment = terraform.workspace
  project     = "terraform-aws-arc-ecs"

  extra_tags = {
    Example = "True"
  }
}

module "ecs_cluster" {
  source = "../../"

  ecs_cluster       = var.ecs_cluster
  capacity_provider = var.capacity_provider
  vpc_id            = data.aws_vpc.default.id
  environment       = var.environment
  ecs_service       = var.ecs_service
  task              = var.task
  lb                = var.lb
  cidr_blocks       = var.cidr_blocks
  alb               = var.alb
  alb_target_group  = var.alb_target_group
  listener_rules    = var.listener_rules
  tags              = module.tags.tags
}
