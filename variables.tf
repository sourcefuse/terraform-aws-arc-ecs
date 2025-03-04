################################################################################
## ecs cluster
################################################################################
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "ecs_cluster" {
  type = object({
    name = string
    create_cluster           = optional(bool, true)
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
  description = "Configuration settings for the ECS capacity providers, including the capacity providers used for autoscaling and Fargate. This variable defines the properties of each capacity provider and how they are managed, such as scaling policies and termination protection."

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
    use_fargate                = bool
    fargate_capacity_providers = any
  })
  default = null
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type        = string
  default = null
}


variable "launch_template" {
  type = object({
    name = string
    block_device_mappings = optional(list(object({
      device_name = string
      ebs = optional(object({
        volume_size = number
      }))
    })), [])

    cpu_options = optional(object({
      core_count       = number
      threads_per_core = number
    }), null)

    disable_api_stop        = optional(bool, false)
    disable_api_termination = optional(bool, false)
    ebs_optimized           = optional(bool, false)

    elastic_gpu_specifications = optional(list(object({
      type = string
    })), [])

    iam_instance_profile = optional(object({
      name = string
    }), null)

    image_id                             = optional(string, null)
    instance_initiated_shutdown_behavior = optional(string, "stop")

    instance_type = optional(string, null)
    kernel_id     = optional(string, null)
    key_name      = optional(string, null)

    monitoring = optional(object({
      enabled = bool
    }), null)

    network_interfaces = optional(list(object({
      associate_public_ip_address = optional(bool, null)
      ipv4_prefixes               = optional(list(string), [])
      ipv6_prefixes               = optional(list(string), [])
      ipv4_addresses              = optional(list(string), [])
      ipv6_addresses              = optional(list(string), [])
      network_interface_id        = optional(string, null)
      private_ip_address          = optional(string, null)
      security_groups             = optional(list(string), [])
      subnet_id                   = optional(string, null)
    })), [])

    placement = optional(object({
      availability_zone = string
    }), null)

    vpc_security_group_ids = optional(list(string), [])

    tag_specifications = optional(list(object({
      resource_type = string
      tags          = map(string)
    })), [])

    user_data = optional(string, null)
  })
  default = null
}

variable "asg" {
  description = "Auto Scaling Group configuration"
  type = object({
    name                = optional(string, null)
    min_size            = number
    max_size            = number
    desired_capacity    = optional(number)
    vpc_zone_identifier = optional(list(string))

    health_check_type         = optional(string)
    health_check_grace_period = optional(number, 300)
    protect_from_scale_in     = optional(bool)
    default_cooldown          = optional(number)

    instance_refresh = optional(object({
      strategy = string
      preferences = optional(object({
        min_healthy_percentage = optional(number)
      }))
    }))
  })
  default = null
}

################################################################################
## ecs service
################################################################################

variable "environment" {
  type        = string
  default = null
  description = "The environment associated with the ECS service"
}

variable "vpc_id" {
  type        = string
  default = null
  description = "ID of VPC in which all resources need to be created"
}

variable "ecs_service" {
  type = object({
    cluster_name             = optional(string)
    service_name             = optional(string)
    repository_name          = optional(string)
    enable_load_balancer     = optional(bool, false)
    aws_lb_target_group_name = optional(string)
    ecs_subnets              = optional(list(string))
    create_service           = optional(bool, false)
  })
  description = "The ECS-specific values to use such as cluster, service, and repository names."
}

# Task-specific variables
variable "task" {
  type = object({
    tasks_desired               = optional(number)
    launch_type                 = optional(string)
    network_mode                = optional(string)
    compatibilities             = optional(list(string))
    container_vcpu              = optional(number)
    container_memory            = optional(number)
    container_port              = number
    container_health_check_path = optional(string)
    container_definition        = optional(string)
    environment_variables       = optional(map(string))
    secrets                     = optional(map(string))
    task_execution_role         = optional(string)
  })
  default = null

  description = "Task-related information (vCPU, memory, # of tasks, port, and health check info.)"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default = null
}

# Load balancer
variable "lb" {
  type = object({
    name                 = string
    listener_port        = number
    deregistration_delay = optional(number)
    security_group_id    = string
  })
  default = null
  description = "ALB-related information (listening port, deletion protection, security group)"
}

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = null
}
