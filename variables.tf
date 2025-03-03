################################################################################
## ecs cluster
################################################################################

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
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type        = string
}

################################################################################
## ecs service
################################################################################

variable "environment" {
  type        = string
  description = "The environment associated with the ECS service"
}


variable "ecs_service" {
  type = object({
    cluster_name             = string
    service_name             = string
    repository_name          = string
    enable_load_balancer     = bool
    aws_lb_target_group_name = optional(string)
    create_service           = optional(bool, false)
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
variable "lb" {
  type = object({
    name                 = string
    listener_port        = number
    deregistration_delay = optional(number)
    security_group_id    = string
  })
  description = "ALB-related information (listening port, deletion protection, security group)"
}
