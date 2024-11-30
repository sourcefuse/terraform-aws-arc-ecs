################################################################################
## defaults
################################################################################
terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

################################################################################
## Load balancer
################################################################################

resource "aws_lb" "this" {
  count = var.create_alb ? 1 : 0

  name                       = var.alb.name
  internal                   = var.alb.internal
  load_balancer_type         = var.alb.load_balancer_type
  security_groups            = [aws_security_group.lb_sg.id]
  subnets                    = [for subnet in aws_subnet.public : subnet.id]
  idle_timeout               = var.alb.idle_timeout
  enable_deletion_protection = var.alb.enable_deletion_protection
  enable_http2               = var.alb.enable_http2

  access_logs {
    bucket  = var.alb.access_logs.bucket
    enabled = var.alb.access_logs.enabled
    prefix  = var.alb.access_logs.prefix
  }
}


## Target Group

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
    for_each = each.value.stickiness != null && each.value.stickiness.enabled ? [each.value.stickiness] : []
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

# Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.alb.port
  protocol          = var.alb.protocol

  certificate_arn   = var.alb.certificate_arn

  dynamic "default_action" {
    for_each = var.listener_rules
    content {
      type             = each.value.actions[0].type
      target_group_arn = lookup(each.value.actions[0], "target_group_arn", null)
    }
  }
}


resource "aws_lb_listener_rule" "this" {
  for_each = var.create_listener_rule ? { for rule in var.listener_rules : "${rule.priority}" => rule } : {}

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
}
