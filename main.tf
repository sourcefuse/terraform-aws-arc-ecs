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

################################################################################
## cluster
################################################################################
module "ecs" {
  source       = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs?ref=v4.1.2"
  cluster_name = local.cluster_name

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"

      log_configuration = {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.this.name
      }
    }
  }

  tags = merge(var.tags, tomap({
    Name = local.cluster_name
  }))
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
## service
################################################################################
#resource "aws_ecs_service" "this" {
#  name            = "${local.cluster_name}-health-check"
#  cluster         = module.ecs.cluster_id
#  task_definition = aws_ecs_task_definition.this.arn
#  launch_type     = "FARGATE" # TODO - change this
#  desired_count   = var.service_desired_count
#
#  health_check_grace_period_seconds = length(var.load_balancers) > 0 ? var.health_check_grace_period_seconds : null
#
#  network_configuration {
#    subnets = var.ecs_service_subnet_ids
#    security_groups = concat(
#      var.additional_service_security_group_ids,
#      [aws_security_group.alb.id],
#      [module.health_check.security_group_id]
#    )
#    assign_public_ip = false
#  }
#
#  dynamic "load_balancer" {
#    for_each = var.load_balancers
#
#    content {
#      target_group_arn = load_balancer.value.target_group_arn
#      container_name   = var.alb_container_name
#      container_port   = var.alb_container_port
#    }
#  }
#
#  dynamic "service_registries" {
#    for_each = var.service_registry_list
#
#    content {
#      registry_arn = service_registries.value.registry_arn
#    }
#  }
#
#  tags = merge(var.tags, tomap({
#    Name = local.cluster_name
#  }))
#}

################################################################################
## task / container definition
################################################################################
## container definition
#module "container_definition" {
#  source   = "git::https://github.com/aws-ia/ecs-blueprints.git//modules/ecs-container-definition?ref=5a80841ac6f2436941c45e7a9cd9b69407b9ab32"
#  for_each = { for x in local.container_definitions : x.name => x }
#
#  name      = each.value.name
#  image     = each.value.image
#  service   = each.value.service
##  memory    = try(each.value.memory, 100) // TODO: remove magic number
##  cpu       = try(each.value.cpu, 512) // TOOD: remove magic number
#  essential = try(each.value.essential, false)
#
#  port_mappings = each.value.port_mappings
#}

## task definition
#resource "aws_ecs_task_definition" "this" {
#  family                   = local.cluster_name
#  requires_compatibilities = var.task_definition_requires_compatibilities
#  network_mode             = var.task_definition_network_mode
#  cpu                      = var.task_definition_cpu
#  memory                   = var.task_definition_memory
#  task_role_arn            = aws_iam_role.task.arn
#  execution_role_arn       = aws_iam_role.execution.arn
#
#  container_definitions = jsonencode([for x in module.container_definition : x.container_definition])
#
#  tags = merge(var.tags, tomap({
#    Name = local.cluster_name
#  }))
#}

################################################################################
## service discovery namespaces
################################################################################
#resource "aws_service_discovery_private_dns_namespace" "this" {
#  for_each = toset(var.service_discovery_private_dns_namespace)
#
#  name        = "${each.key}.${local.cluster_name}.local"
#  description = "Service discovery for ${each.key}.${local.cluster_name}.local" # TODO - update this if needed. .local should be configurable
#  vpc         = var.vpc_id
#}

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

################################################################################
## load balancer
################################################################################
## certificate
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

  tags = var.tags
}

## security groups
resource "aws_security_group" "alb" {
  name   = "${local.cluster_name}-alb"
  vpc_id = var.vpc_id

  // TODO - make dynamic
  ingress {
    from_port        = 80
    protocol         = "tcp"
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    protocol         = "tcp"
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  // TODO - tighten this down to only go to the task subnets
  egress {
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, tomap({
    Name = "${local.cluster_name}-alb"
  }))
}

## alb
module "alb" {
  source = "./modules/alb"

  namespace          = var.namespace
  environment        = var.environment
  vpc_id             = var.vpc_id
  subnet_ids         = var.alb_subnet_ids
  security_group_ids = [aws_security_group.alb.id]

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

data "aws_route53_zone" "health_check" {
  name = var.route_53_zone
}


// TODO - determine if this is needed / if needs to be consolidated to root
module "health_check" {
  source = "./modules/health-check"

  vpc_id     = var.vpc_id
  subnet_ids = length(var.health_check_subnet_ids) > 0 ? var.health_check_subnet_ids : var.alb_subnet_ids

  cluster_id   = module.ecs.cluster_id
  cluster_name = module.ecs.cluster_name
  #  service_task_definition = aws_ecs_task_definition.this.arn

  lb_listener_arn       = aws_lb_listener.https.arn
  lb_security_group_ids = [aws_security_group.alb.id]

  tags = var.tags

  depends_on = [
    module.ecs,
    module.alb
  ]
  alb_dns_name         = module.alb.alb_dns_name
  alb_zone_id          = module.alb.alb_zone_id
  health_check_domains = ["healthcheck-ecs-example.sfrefarch.com"]
  route_53_zone_id     = data.aws_route53_zone.health_check.zone_id
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
  certificate_arn   = module.acm.arn

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
}
