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
  zone_name                         = var.route_53_zone
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

  namespace          = var.namespace
  environment        = var.environment
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

  ## for internal records on health check
  route_53_zone_name   = var.route_53_zone
  health_check_domains = var.health_check_domains

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
}
