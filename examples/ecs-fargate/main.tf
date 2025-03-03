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

  ecs_cluster       = local.ecs_cluster
  capacity_provider = local.capacity_provider
  environment       = local.environment
  ecs_service       = local.ecs_service
  task              = local.task
  lb                = local.lb
  # cidr_blocks       = var.cidr_blocks
  target_group_arn  = module.alb.target_group_arn
  tags              = module.tags.tags
  depends_on = [module.alb]
}

################################################################################
## application load balancer
################################################################################
module "alb" {
  source                         = "sourcefuse/arc-load-balancer/aws"
  version                        = "0.0.1"
  load_balancer_config           = local.load_balancer_config
  target_group_config            = local.target_group_config
  alb_listener                   = local.alb_listener
  default_action                 = local.default_action
  listener_rules                 = local.listener_rules
  security_group_data            = local.security_group_data
  security_group_name            = local.security_group_name
  vpc_id                         = data.aws_vpc.default.id
  tags                           = module.tags.tags
}
