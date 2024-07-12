################################################################################
## defaults
################################################################################
terraform {
  required_version = ">= 1.4, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0, < 6.0"
    }
  }
}

################################################################################
## cluster
################################################################################
module "ecs" {
  source       = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs?ref=v5.11.1"
  cluster_name = local.cluster_name

  cluster_configuration = {
    execute_command_configuration = {
      kms_key_id = var.ecs_kms_key_arn_override != "" ? var.ecs_kms_key_arn_override : (var.enabled ? module.kms.key_arn : "")
      logging    = "OVERRIDE"

      log_configuration = {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.this.name
      }
    }
  }

  tags = merge(var.tags, tomap({
    Name = local.cluster_name
  }))
}
module "kms" {
  source                  = "sourcefuse/arc-kms/aws"
  version                 = "1.0.0"
  enabled                 = var.enabled
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  alias                   = var.alias
  tags                    = var.tags
  policy                  = var.policy
}

## logging
resource "aws_cloudwatch_log_group" "this" {
  name = "/${var.namespace}/${var.environment}/ecs/${local.cluster_name}"

  retention_in_days = var.log_group_retention_days
  skip_destroy      = var.log_group_skip_destroy

  tags = merge(var.tags, tomap({
    Name = "/${var.namespace}/${var.environment}/ecs/${local.cluster_name}"
  }))
}

################################################################################
## load balancer
################################################################################
## certificate
module "acm" {
  source = "git::https://github.com/cloudposse/terraform-aws-acm-request-certificate?ref=0.17.0"
  count  = var.create_acm_certificate == true ? 1 : 0

  name                              = "${var.environment}-${var.namespace}-acm-certificate"
  namespace                         = var.namespace
  environment                       = var.environment
  zone_name                         = var.route_53_zone_name
  domain_name                       = var.acm_domain_name
  subject_alternative_names         = var.acm_subject_alternative_names
  process_domain_validation_options = var.acm_process_domain_validation_options
  ttl                               = var.acm_process_domain_validation_record_ttl

  tags = var.tags
}

module "alb_sg" {
  source = "git::https://github.com/cloudposse/terraform-aws-security-group?ref=2.0.0"

  # Security Group names must be unique within a VPC.
  # This module follows Cloud Posse naming conventions and generates the name
  # based on the inputs to the null-label module, which means you cannot
  # reuse the label as-is for more than one security group in the VPC.
  #
  # Here we add an attribute to give the security group a unique name.
  attributes = ["${local.cluster_name}-alb"]

  # Allow unlimited egress
  allow_all_egress = true

  rules = [
    {
      key              = "alb-ingress-80"
      type             = "ingress"
      from_port        = 80
      protocol         = "tcp"
      to_port          = 80
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      self             = null # preferable to self = false
      description      = "Allow port 80 from anywhere"
    },
    {
      key              = "alb-ingress-443"
      type             = "ingress"
      from_port        = 443
      protocol         = "tcp"
      to_port          = 443
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      self             = null # preferable to self = false
      description      = "Allow port 443 from anywhere"
    }
  ]

  vpc_id = var.vpc_id

  tags = merge(var.tags, tomap({
    Name = "${local.cluster_name}-alb"
  }))
}

## alb
module "alb" {
  source = "./modules/alb"

  name               = local.cluster_name
  vpc_id             = var.vpc_id
  subnet_ids         = var.alb_subnet_ids
  security_group_ids = [module.alb_sg.id]

  access_logs_enabled                             = var.access_logs_enabled
  alb_access_logs_s3_bucket_force_destroy         = var.alb_access_logs_s3_bucket_force_destroy
  alb_access_logs_s3_bucket_force_destroy_enabled = var.alb_access_logs_s3_bucket_force_destroy_enabled
  internal                                        = var.alb_internal
  idle_timeout                                    = var.alb_idle_timeout

  // TODO - change to variable
  http_ingress_cidr_blocks = [
    "0.0.0.0/0"
  ]

  // TODO - change to variable
  https_ingress_cidr_blocks = [
    "0.0.0.0/0"
  ]

  tags = var.tags
}

module "health_check" {
  source = "./modules/health-check"

  vpc_id     = var.vpc_id
  subnet_ids = length(var.health_check_subnet_ids) > 0 ? var.health_check_subnet_ids : var.alb_subnet_ids

  cluster_id   = module.ecs.cluster_id
  cluster_name = module.ecs.cluster_name

  lb_listener_arn       = aws_lb_listener.https.arn
  lb_security_group_ids = [module.alb_sg.id]

  ## for alb alias records
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id

  externally_managed_route_53_record = var.externally_managed_route_53_record

  ## health check
  route_53_zone_id              = var.route_53_zone_id
  health_check_route_53_records = var.health_check_route_53_records

  task_execution_role_arn = aws_iam_role.execution.arn

  tags = var.tags

  depends_on = [
    module.ecs,
    module.alb
  ]
}

################################################################################
## listeners
################################################################################
## http
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

  tags = merge(var.tags, tomap({
    Name = "${local.cluster_name}-http-redirect"
  }))
}

## https
resource "aws_lb_listener" "https" {
  load_balancer_arn = module.alb.alb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.alb_ssl_policy
  certificate_arn   = try(module.acm[0].arn, var.alb_certificate_arn)

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }

  tags = merge(var.tags, tomap({
    Name = "${local.cluster_name}-https-forward"
  }))

  depends_on = [
    module.acm
  ]
}

################################################################################
## service discovery namespaces
################################################################################
resource "aws_service_discovery_private_dns_namespace" "this" {
  for_each = toset(var.service_discovery_private_dns_namespace)

  name        = each.value
  description = "Service discovery for ${each.value}"
  vpc         = var.vpc_id
}

################################################################################
## ssm parameters
################################################################################
resource "aws_ssm_parameter" "this" {
  for_each = { for x in local.ssm_params : x.name => x }

  name        = each.value.name
  value       = each.value.value
  description = try(each.value.description, "Managed by Terraform")
  type        = try(each.value.type, "SecureString")
  overwrite   = try(each.value.overwrite, true)

  tags = merge(var.tags, tomap({
    Name = each.value.name
  }))
}
