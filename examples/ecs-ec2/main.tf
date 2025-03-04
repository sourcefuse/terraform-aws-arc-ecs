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
  # for_each = local.ecs_services

  ecs_cluster       = local.ecs_cluster
  capacity_provider = local.capacity_provider
  ecs_service       = local.ecs_service
  launch_template   = local.launch_template
  asg               = local.asg
  tags              = module.tags.tags
}

# module "ecs_cluster" {
#   source   = "../../"
#   for_each = local.ecs_services

#   ecs_cluster       = local.ecs_cluster
#   capacity_provider = local.capacity_provider
#   launch_template   = local.launch_template
#   asg               = local.asg
#   ecs_service       = each.value.ecs_service
#   task              = each.value.task
#   lb_data           = each.value.lb_data
#   vpc_id            = data.aws_vpc.default.id
#   target_group_arn  = module.alb.target_group_arn
#   environment       = var.environment
#   tags              = module.tags.tags
#   depends_on        = [module.alb]
# }

module "ecs_services" {
  for_each = local.ecs_services

  source           = "../../"
  ecs_cluster      = each.value.ecs_cluster
  ecs_cluster_name = local.ecs_cluster.name
  ecs_service      = each.value.ecs_service
  task             = each.value.task
  lb_data          = each.value.lb_data
  vpc_id           = data.aws_vpc.default.id
  target_group_arn = module.alb.target_group_arn
  environment      = var.environment
  tags             = module.tags.tags
  depends_on       = [module.ecs_cluster, module.alb]

}

################################################################################
## application load balancer
################################################################################
module "alb" {
  source               = "sourcefuse/arc-load-balancer/aws"
  version              = "0.0.1"
  load_balancer_config = local.load_balancer_config
  target_group_config  = local.target_group_config
  alb_listener         = local.alb_listener
  default_action       = local.default_action
  listener_rules       = local.listener_rules
  security_group_data  = local.security_group_data
  security_group_name  = local.security_group_name
  vpc_id               = data.aws_vpc.default.id
  tags                 = module.tags.tags
}
