################################################################################
## ecs cluster
################################################################################

variable "ecs_cluster" {
  type = object({
    name = string
    configuration = optional(object({
      execute_command_configuration = optional(object({
        kms_key_id = optional(string, "")
        logging    = optional(string, "DEFAULT")
        log_configuration = optional(object({
          cloudwatch_encryption_enabled = optional(bool, null)
          log_group_name                = optional(string, null)
          log_group_retention_in_days   = optional(number, null)
          log_group_kms_key_id          = optional(string, null)
          log_group_tags                = optional(map(string), null)
          s3_bucket_name                = optional(string, null)
          s3_bucket_encryption_enabled  = optional(bool, null)
          s3_key_prefix                 = optional(string, null)
        }), {})
      }), {})
    }), {})
    create_cloudwatch_log_group = bool
    service_connect_defaults    = optional(map(string), null)
    settings                    = optional(any, null)
    tags                        = optional(map(string), null)
  })
  description = <<EOT
The ECS-specific values to use such as cluster, service, and repository names.

Keys:
  - cluster_name: The name of the ECS cluster.
  - cluster_configuration: The execute command configuration for the cluster.
  - cluster_settings: A list of cluster settings (e.g., container insights). Default is an empty list.
  - cluster_service_connect_defaults: Configures a default Service Connect namespace.
  - create_cloudwatch_log_group: Boolean flag to specify whether to create a CloudWatch log group for the ECS cluster.
EOT
}

variable "capacity_provider" {
  type = object({
    autoscaling_capacity_providers = map(object({
      name                           = optional(string)
      auto_scaling_group_arn         = string
      managed_termination_protection = optional(string, "DISABLED")
      managed_draining               = optional(string, "ENABLED")
      managed_scaling = optional(object({
        instance_warmup_period    = optional(number)
        maximum_scaling_step_size = optional(number)
        minimum_scaling_step_size = optional(number)
        status                    = optional(string)
        target_capacity           = optional(number)
      }))
      tags = optional(map(string), {})
    }))
    default_capacity_provider_use_fargate = bool
    fargate_capacity_providers            = any
  })
}

################################################################################
##  ALB
################################################################################

variable "vpc_id" {
  type = string
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
    target_type                       = optional(string, "ip")
    ip_address_type                   = optional(string, "ipv4")
    load_balancing_algorithm_type     = optional(string, "round_robin")
    load_balancing_cross_zone_enabled = optional(string, "use_load_balancer_configuration")
    deregistration_delay              = optional(number, 300)
    slow_start                        = optional(number, 0)
    tags                              = optional(map(string), {})

    health_check = optional(object({
      enabled             = optional(bool, true)
      protocol            = optional(string, "HTTP") 
      path                = optional(string, "/")
      port                = optional(string, "traffic-port")
      timeout             = optional(number, 6)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      interval            = optional(number, 30)
      matcher             = optional(string, "200") 
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

################################################################################
## ecs service
################################################################################

variable "environment" {
  type        = string
  description = "The environment associated with the service"
}


variable "ecs" {
  type = object({
    cluster_name             = string
    service_name             = string
    repository_name          = string
    enable_load_balancer     = bool
    aws_lb_target_group_name = optional(string)
  })
  description = "The ECS-specific values to use such as cluster, service, and repository names."
}

# Task-specific variables
variable "task" {
  type = object({
    tasks_desired               = optional(number)      
    container_vcpu              = optional(number)      
    container_memory            = optional(number)      
    container_port              = number               
    container_health_check_path = optional(string)      
    container_definition        = optional(string)      
    environment_variables       = optional(map(string)) 
    task_execution_role         = optional(string)      
  })

  description = "Task-related information (vCPU, memory, # of tasks, port, and health check info.)"
}

# Load balancer
variable "alb" {
  type = object({
    name                 = string
    listener_port        = number
    deregistration_delay = optional(number)
    security_group_id    = string
  })
  description = "ALB-related information (listening port, deletion protection, security group)"
}
