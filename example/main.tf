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
  source = "git::https://github.com/sourcefuse/terraform-aws-refarch-tags?ref=1.1.0"

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
## ecs
################################################################################
module "ecs" {
  source = "../"

  environment = var.environment
  namespace   = var.namespace

  vpc_id                  = data.aws_vpc.vpc.id
  alb_subnet_ids          = data.aws_subnets.public.ids
  health_check_subnet_ids = data.aws_subnets.private.ids

  // --- Devs: DO NOT override, otherwise tests will fail --- //
  access_logs_enabled                             = false
  alb_access_logs_s3_bucket_force_destroy         = true
  alb_access_logs_s3_bucket_force_destroy_enabled = true
  // -------------------------- END ------------------------- //

  ## create acm certificate and dns record for health check
  route_53_zone_name            = local.route_53_zone
  route_53_zone_id              = data.aws_route53_zone.this.id
  acm_domain_name               = "healthcheck-ecs-${var.namespace}-${var.environment}.${local.route_53_zone}"
  acm_subject_alternative_names = []
  health_check_route_53_records = [
    "healthcheck-ecs-${var.namespace}-${var.environment}.${local.route_53_zone}"
  ]

  service_discovery_private_dns_namespace = [
    "${var.namespace}.${var.environment}.${local.route_53_zone}"
  ]

  tags = module.tags.tags
}
