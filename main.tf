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
## ecs
################################################################################
## cluster
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

################################################################################
## logging
################################################################################
resource "aws_cloudwatch_log_group" "this" {
  name = "/${var.namespace}/${var.environment}/ecs/${local.cluster_name}"

  retention_in_days = var.log_group_retention_days
  skip_destroy      = var.log_group_skip_destroy

  tags = merge(var.tags, tomap({
    Name = "/${var.namespace}/${var.environment}/ecs/${local.cluster_name}"
  }))
}

################################################################################
## service discovery namespaces
################################################################################
resource "aws_service_discovery_private_dns_namespace" "this" {
  for_each = toset(var.service_discovery_private_dns_namespace)

  name        = "${each.key}.${local.cluster_name}.local"
  description = "Service discovery for ${each.key}.${local.cluster_name}.local" # TODO - update this if needed
  vpc         = var.vpc_id
}

################################################################################
## task execution role
################################################################################
## execution
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name_prefix        = "${local.cluster_name}-execution-"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = merge(var.tags, tomap({
    NamePrefix = "${local.cluster_name}-execution-"
  }))
}

resource "aws_iam_policy_attachment" "execution" {
  for_each = toset(var.execution_policy_attachment_arns)

  name       = "${local.cluster_name}-execution"
  policy_arn = each.value
  roles      = [aws_iam_role.execution.name]
}

## secrets manager
resource "aws_iam_policy" "secrets_manager_read_policy" {
  name = "${local.cluster_name}-secrets-manager-ro"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Resource = "*"
        Action = [
          "secretsmanager:GetSecretValue"
        ],
      }
    ]
  })

  tags = merge(var.tags, tomap({
    Name = "${local.cluster_name}-secrets-manager-ro"
  }))
}

resource "aws_iam_policy_attachment" "secrets_manager_read" {
  name       = "${local.cluster_name}-secrets-manager-ro"
  roles      = [aws_iam_role.execution.name]
  policy_arn = aws_iam_policy.secrets_manager_read_policy.arn
}

################################################################################
## load balancer
################################################################################
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

## health check
module "health_check" {
  source = "./modules/health-check"

  vpc_id     = var.vpc_id
  subnet_ids = length(var.health_check_subnet_ids) > 0 ? var.health_check_subnet_ids : var.alb_subnet_ids

  task_execution_role_arn = aws_iam_role.execution.arn

  cluster_id   = module.ecs.cluster_id
  cluster_name = local.cluster_name

  lb_listener_arn       = aws_lb_listener.https.arn
  lb_security_group_ids = [aws_security_group.alb.id]

  tags = var.tags

  depends_on = [
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
  certificate_arn   = var.alb_acm_certificate_arn

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
