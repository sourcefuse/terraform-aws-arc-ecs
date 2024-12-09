###################################################################
## defaults
###################################################################
terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

###################################################################
## Load balancer Security Group
###################################################################
resource "aws_security_group" "lb_sg" {
  name        = "${var.alb.name}-sg"
  description = "Default security group for internet facing ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.cidr_blocks
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###################################################################
## Application Load balancer
###################################################################
resource "aws_lb" "this" {
  name                       = var.alb.name
  internal                   = var.alb.internal
  load_balancer_type         = var.alb.load_balancer_type
  security_groups            = [aws_security_group.lb_sg.id]
  subnets                    = local.public_subnets
  idle_timeout               = var.alb.idle_timeout
  enable_deletion_protection = var.alb.enable_deletion_protection
  enable_http2               = var.alb.enable_http2

  dynamic "access_logs" {
    for_each = var.alb.access_logs != null ? [var.alb.access_logs] : []

    content {
      bucket  = access_logs.value.bucket
      enabled = access_logs.value.enabled
      prefix  = access_logs.value.prefix
    }
  }
}


###################################################################
## Target Group
###################################################################

resource "aws_lb_target_group" "this" {
  for_each = { for tg in var.alb_target_group : tg.name => tg }

  name                              = each.value.name
  port                              = each.value.port
  protocol                          = each.value.protocol
  protocol_version                  = each.value.protocol_version
  vpc_id                            = each.value.vpc_id
  target_type                       = each.value.target_type
  ip_address_type                   = each.value.ip_address_type
  load_balancing_algorithm_type     = each.value.load_balancing_algorithm_type
  load_balancing_cross_zone_enabled = each.value.load_balancing_cross_zone_enabled
  deregistration_delay              = each.value.deregistration_delay
  slow_start                        = each.value.slow_start

  health_check {
    enabled             = each.value.health_check.enabled
    protocol            = each.value.health_check.protocol
    path                = each.value.health_check.path
    port                = each.value.health_check.port
    timeout             = each.value.health_check.timeout
    healthy_threshold   = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
    interval            = each.value.health_check.interval
    matcher             = each.value.health_check.matcher
  }

  dynamic "stickiness" {
    for_each = each.value.stickiness != null ? [each.value.stickiness] : []
    content {
      cookie_duration = stickiness.value.cookie_duration
      type            = stickiness.value.type
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = each.value.tags
}

###################################################################
## Listener
###################################################################

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.alb.port
  protocol          = var.alb.protocol

  certificate_arn = var.alb.certificate_arn

  # Static "default_action" for forward
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[var.alb_target_group[0].name].arn
  }

  # Dynamic "default_action" for variable-driven actions
  dynamic "default_action" {
    for_each = var.listener_rules

    content {
      type             = length(each.value.actions) > 0 ? each.value.actions[0].type : null
      target_group_arn = length(each.value.actions) > 0 ? lookup(each.value.actions[0], "target_group_arn", null) : null
    }
  }
  depends_on = [aws_lb_target_group.this]
}


###################################################################
## Listener Rules
###################################################################
resource "aws_lb_listener_rule" "this" {
  for_each = var.create_listener_rule ? { for rule in var.listener_rules : rule.priority => rule } : {}

  listener_arn = aws_lb_listener.http.arn
  priority     = each.value.priority

  dynamic "condition" {
    for_each = each.value.conditions
    content {
      dynamic "host_header" {
        for_each = each.value.field == "host-header" ? [each.value] : []
        content {
          values = each.value.values
        }
      }

      dynamic "path_pattern" {
        for_each = each.value.field == "path-pattern" ? [each.value] : []
        content {
          values = each.value.values
        }
      }
    }
  }

  dynamic "action" {
    for_each = each.value.actions
    content {
      type             = action.value.type
      target_group_arn = lookup(action.value, "target_group_arn", aws_lb_target_group.this.arn)
      order            = lookup(action.value, "order", null)
      redirect {
        protocol    = lookup(action.value.redirect, "protocol", null)
        port        = lookup(action.value.redirect, "port", null)
        host        = lookup(action.value.redirect, "host", null)
        path        = lookup(action.value.redirect, "path", null)
        query       = lookup(action.value.redirect, "query", null)
        status_code = lookup(action.value.redirect, "status_code", null)
      }
      fixed_response {
        content_type = lookup(action.value.fixed_response, "content_type", null)
        message_body = lookup(action.value.fixed_response, "message_body", null)
        status_code  = lookup(action.value.fixed_response, "status_code", null)
      }
    }
  }

  depends_on = [aws_lb_listener.http]
}
