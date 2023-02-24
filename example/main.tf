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
  source = "git::https://github.com/sourcefuse/terraform-aws-refarch-tags?ref=1.0.2"

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

  vpc_id                  = data.aws_vpc.vpc.id
  alb_subnet_ids          = data.aws_subnets.public.ids
  health_check_subnet_ids = data.aws_subnets.private.ids
  alb_acm_certificate_arn = module.acm.arn

  tags = module.tags.tags
}
