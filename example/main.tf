################################################################################
## defaults
################################################################################
terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

module "tags" {
  source = "git@github.com:sourcefuse/terraform-aws-refarch-tags?ref=1.0.2"

  environment = var.environment
  project     = "Example"

  extra_tags = {
    RepoName = "terraform-aws-refarch-ecs"
    Example  = "true"
  }
}

provider "aws" {
  region = var.region
}

################################################################################
## lookups
################################################################################
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = var.vpc_names
  }
}

## private
// TODO - remove if not needed in future
#data "aws_subnets" "private" {
#  filter {
#    name = "tag:Name"
#
#    values = var.alb_private_subnet_names
#  }
#}

// TODO - remove if not needed in future
#data "aws_subnet" "private" {
#  for_each = toset(data.aws_subnets.private.ids)
#  id       = each.value
#}

## public
data "aws_subnets" "public" {
  filter {
    name = "tag:Name"

    values = var.public_subnet_names
  }
}

// TODO - remove if not needed in future
#data "aws_subnet" "public" {
#  for_each = toset(data.aws_subnets.public.ids)
#  id       = each.value
#}

## security group
data "aws_security_groups" "web_sg" {
  filter {
    name   = "group-name"
    values = var.web_security_group_names
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

## cluster ami
data "aws_ami" "this" {
  owners      = var.ami_owners
  most_recent = "true"

  dynamic "filter" {
    for_each = var.ami_filter

    content {
      name   = filter.key
      values = filter.value
    }
  }
}

################################################################################
## ecs
################################################################################
module "ecs" {
  source = "../"

  environment = var.environment
  namespace   = var.namespace
  region      = var.region

  vpc_id                             = data.aws_vpc.vpc.id
  alb_subnets_ids                    = data.aws_subnets.public.ids
  alb_security_group_ids             = data.aws_security_groups.web_sg.ids
  autoscaling_subnet_names           = var.private_subnet_names
  cluster_image_id                   = data.aws_ami.this.image_id
  kms_admin_iam_role_identifier_arns = var.kms_admin_iam_role_identifier_arns

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  autoscaling_capacity_providers = {}

  tags = module.tags.tags
}
