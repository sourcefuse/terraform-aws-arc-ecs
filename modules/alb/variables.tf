variable "create_alb" {
  type        = bool
  default     = false
  description = "A flag that decides whether to create alb"
}

variable "create_listener_rule" {
  type    = bool
  default = false
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type        = string
  description = "VPC in which security group for ALB has to be created"
}

variable "alb" {
  type = object({
    name                       = optional(string, null)
    port                       = optional(number)
    protocol                   = optional(string, "HTTP")
    internal                   = optional(bool, false)
    load_balancer_type         = optional(string, "application")
    idle_timeout               = optional(number, 60)
    enable_deletion_protection = optional(bool, false)
    enable_http2               = optional(bool, true)
    certificate_arn            = optional(string, null)
    subnets                = list(string)

    access_logs = optional(object({
      bucket  = string
      enabled = optional(bool, false)
      prefix  = optional(string, "")
    }))

    tags = optional(map(string), {})
  })
}


variable "alb_target_group" {
  description = "List of target groups to create"
  type = list(object({
    name                              = optional(string, "target-group")
    port                              = number
    protocol                          = optional(string, null)
    protocol_version                  = optional(string, "HTTP1")
    vpc_id                            = optional(string, "")
    target_type                       = optional(string, "instance")
    ip_address_type                   = optional(string, "ipv4")
    load_balancing_algorithm_type     = optional(string, "round_robin")
    load_balancing_cross_zone_enabled = optional(string, "use_load_balancer_configuration")
    deregistration_delay              = optional(number, 300)
    slow_start                        = optional(number, 0)
    tags                              = optional(map(string), {})

    health_check = optional(object({
      enabled             = optional(bool, true)
      protocol            = optional(string, "HTTP") # Allowed values: "HTTP", "HTTPS", "TCP", etc.
      path                = optional(string, "/")
      port                = optional(string, "traffic-port")
      timeout             = optional(number, 6)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      interval            = optional(number, 30)
      matcher             = optional(string, "200") # Default HTTP matcher. Range 200 to 499
    }))

    stickiness = optional(object({
      enabled         = optional(bool, true)
      type            = string
      cookie_duration = optional(number, 86400)
      })
    )

  }))
}

variable "listener_rules" {
  description = "List of listener rules to create"
  type = list(object({
    # listener_arn = string
    priority = number

    conditions = list(object({
      field  = string
      values = list(string)
    }))

    actions = list(object({
      type             = string
      target_group_arn = optional(string)
      order            = optional(number)
      redirect = optional(object({
        protocol    = string
        port        = string
        host        = optional(string)
        path        = optional(string)
        query       = optional(string)
        status_code = string
      }), null)

      fixed_response = optional(object({
        content_type = string
        message_body = optional(string)
        status_code  = optional(string)
      }), null)

    }))

  }))
}
