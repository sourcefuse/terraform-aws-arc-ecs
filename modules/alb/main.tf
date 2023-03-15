################################################################################
## defaults
################################################################################
terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.30"
    }
  }
}

################################################################################
## Load balancer
################################################################################
module "alb" {
  source = "git::https://github.com/cloudposse/terraform-aws-alb?ref=1.5.0"

  name               = var.name
  vpc_id             = var.vpc_id
  security_group_ids = var.security_group_ids
  subnet_ids         = var.subnet_ids

  // --- DO NOT change values here  --- //
  http_enabled                 = false
  http_redirect                = false
  https_enabled                = false
  drop_invalid_header_fields   = false
  default_target_group_enabled = false
  // -------------- END --------------- //

  internal                          = var.internal
  http2_enabled                     = true
  cross_zone_load_balancing_enabled = var.cross_zone_load_balancing_enabled
  idle_timeout                      = var.idle_timeout
  deregistration_delay              = var.deregistration_delay
  ip_address_type                   = var.ip_address_type
  deletion_protection_enabled       = var.deletion_protection_enabled

  health_check_path                = "/"       // TODO - make into variable
  health_check_matcher             = "200-399" // TODO - make into variable
  health_check_timeout             = 10        // TODO - make into variable
  health_check_healthy_threshold   = 2         // TODO - make into variable
  health_check_unhealthy_threshold = 2         // TODO - make into variable
  health_check_interval            = 15        // TODO - make into variable

  alb_access_logs_s3_bucket_force_destroy         = var.alb_access_logs_s3_bucket_force_destroy
  alb_access_logs_s3_bucket_force_destroy_enabled = var.alb_access_logs_s3_bucket_force_destroy_enabled

  glacier_transition_days   = 60 // TODO - make into variable.
  access_logs_enabled       = var.access_logs_enabled
  enable_glacier_transition = true // TODO - make into variable.

  security_group_enabled    = true
  http_ingress_cidr_blocks  = var.http_ingress_cidr_blocks
  http_port                 = 80
  https_port                = 443
  https_ingress_cidr_blocks = var.https_ingress_cidr_blocks

  tags = var.tags
}
