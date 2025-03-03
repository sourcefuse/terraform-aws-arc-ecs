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

  ecs_cluster = local.ecs_cluster
  capacity_provider = local.capacity_provider
  launch_template = local.launch_template
  asg = local.asg
   tags            = module.tags.tags
}


#   ecs_cluster = {
#     name                        = var.ecs_cluster.name
#     configuration               = var.ecs_cluster.configuration
#     create_cloudwatch_log_group = var.ecs_cluster.create_cloudwatch_log_group
#     service_connect_defaults    = var.ecs_cluster.service_connect_defaults
#     settings                    = var.ecs_cluster.settings
#   }

#   capacity_provider = {
#     autoscaling_capacity_providers = var.capacity_provider.autoscaling_capacity_providers
#     use_fargate                    = var.capacity_provider.use_fargate
#     fargate_capacity_providers     = var.capacity_provider.fargate_capacity_providers
#   }
#   launch_template = var.launch_template
#   asg             = var.asg
#   tags            = var.tags
# }
