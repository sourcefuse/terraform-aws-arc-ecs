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

// TODO - determine if this is needed / if needs to be consolidated to root
module "health_check" {
  source = "./modules/health-check"

  vpc_id     = var.vpc_id
  subnet_ids = length(var.health_check_subnet_ids) > 0 ? var.health_check_subnet_ids : var.alb_subnet_ids

  cluster_id              = module.ecs.cluster_id
  cluster_name            = module.ecs.cluster_name
  service_task_definition = aws_ecs_task_definition.this.arn

  lb_listener_arn = aws_lb_listener.https.arn
  lb_security_group_ids = [aws_security_group.alb.id]

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
