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
  namespace          = var.namespace
  stage              = var.environment
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

  http_ingress_cidr_blocks  = var.http_ingress_cidr_blocks
  https_ingress_cidr_blocks = var.https_ingress_cidr_blocks

  tags = var.tags
}

## create the http redirect listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = module.alb.alb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = var.tags
}

## set up https listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = module.alb.alb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.lb_ssl_policy
  certificate_arn   = var.acm_certificate_arn
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }

  tags = var.tags
}

## create the target groups
resource "aws_lb_target_group" "this" {
  for_each = { for x in var.alb_target_groups : x.name => x }

  name        = each.value.name
  port        = each.value.port
  protocol    = each.value.protocol
  target_type = try(each.value.target_type, "ip")
  vpc_id      = var.vpc_id

  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  tags = var.tags
}

## create the forward rule for the default
resource "aws_lb_listener_rule" "forward" {
  for_each = { for x in var.alb_target_groups : x.name => x }

  listener_arn = aws_lb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.name].arn
  }

  condition {
    host_header {
      values = try(each.value.host_headers, [])
    }
  }

  condition {
    path_pattern {
      values = try(each.value.path_pattern, [])
    }
  }

  tags = var.tags
}
