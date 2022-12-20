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
## certificates // TODO: this should get generated inside the module for convenience
################################################################################
module "acm" {
  source = "git::https://github.com/cloudposse/terraform-aws-acm-request-certificate?ref=0.17.0"

  name                              = "${var.environment}-${var.namespace}-acm-certificate"
  namespace                         = var.namespace
  environment                       = var.environment
  zone_name                         = trimprefix(var.acm_domain_name, "*.")
  domain_name                       = var.acm_domain_name
  subject_alternative_names         = var.acm_subject_alternative_names
  process_domain_validation_options = true
  ttl                               = "300"

  tags = module.tags.tags
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
  alb_security_group_ids             = []
  task_subnet_ids                    = data.aws_subnets.private.ids
  kms_admin_iam_role_identifier_arns = var.kms_admin_iam_role_identifier_arns
  alb_acm_certificate_arn            = module.acm.arn
  health_check_route53_zone          = var.health_check_route53_zone

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

  tags = module.tags.tags
}
