variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
#################################################################
# Cluster
#################################################################

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

  default = {
    name          = ""
    configuration = {}
    settings = [
      {
        name  = "containerInsights"
        value = "enabled"
      }
    ]
    service_connect_defaults    = {}
    create_cloudwatch_log_group = true
  }
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
    
    iam_instance_profile = optional(string)

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
# Cluster Capacity Providers
################################################################################

variable "capacity_provider" {
  type = object({
    autoscaling_capacity_providers = map(object({
      name                           = optional(string)             # Optional; use key if not provided
      auto_scaling_group_arn         = string                       # Required
      managed_termination_protection = optional(string, "DISABLED") # Optional; default to DISABLED
      managed_draining               = optional(string, "ENABLED")  # Optional; default to ENABLED
      managed_scaling = optional(object({
        instance_warmup_period    = optional(number)
        maximum_scaling_step_size = optional(number)
        minimum_scaling_step_size = optional(number)
        status                    = optional(string)
        target_capacity           = optional(number)
      }))
      tags = optional(map(string), {}) # Optional; default to empty map
    }))
    use_fargate                = bool
    fargate_capacity_providers = any
  })
}

########## alb security group config ##########
variable "security_group_data" {
  type = object({
    security_group_ids_to_attach = optional(list(string), [])
    create                       = optional(bool, true)
    description                  = optional(string, null)
    ingress_rules = optional(list(object({
      description              = optional(string, null)
      cidr_block               = optional(string, null)
      source_security_group_id = optional(string, null)
      from_port                = number
      ip_protocol              = string
      to_port                  = string
      self                     = optional(bool, false)
    })), [])
    egress_rules = optional(list(object({
      description                   = optional(string, null)
      cidr_block                    = optional(string, null)
      destination_security_group_id = optional(string, null)
      from_port                     = number
      ip_protocol                   = string
      to_port                       = string
      prefix_list_id                = optional(string, null)
    })), [])
  })
  description = "(optional) Security Group data"
  default = {
    create = false
  }
}

variable "additional_launch_template_policy_arns" {
  description = "List of additional IAM policy ARNs to attach to the IAM role"
  type        = list(string)
  default     = [] # Making it optional by providing an empty list as the default
}

variable "vpc_id" {
  description = "The VPC ID for the resources"
  type        = string
}
