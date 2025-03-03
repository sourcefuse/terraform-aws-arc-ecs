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

