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
