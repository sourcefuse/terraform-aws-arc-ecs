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

resource "aws_ecs_cluster" "this" {
  count = var.create ? 1 : 0

  name = var.ecs_cluster.cluster_name

  dynamic "configuration" {
    for_each = var.ecs_cluster.create_cloudwatch_log_group ? [var.ecs_cluster.cluster_configuration] : []

    content {
      dynamic "execute_command_configuration" {
        for_each = length(configuration.value.execute_command_configuration) > 0 ? [configuration.value.execute_command_configuration] : []

        content {
          kms_key_id = length(execute_command_configuration.value.kms_key_id) > 0 ? execute_command_configuration.value.kms_key_id : ""
          logging    = length(execute_command_configuration.value.logging) > 0 ? execute_command_configuration.value.logging : "DEFAULT"

          dynamic "log_configuration" {
            for_each = length(execute_command_configuration.value.log_configuration) > 0 ? [execute_command_configuration.value.log_configuration] : []

            content {
              cloud_watch_encryption_enabled = log_configuration.value.cloud_watch_encryption_enabled
              cloud_watch_log_group_name     = log_configuration.value.cloud_watch_log_group_name
              s3_bucket_name                 = log_configuration.value.s3_bucket_name
              s3_bucket_encryption_enabled   = log_configuration.value.s3_bucket_encryption_enabled
              s3_key_prefix                  = log_configuration.value.s3_key_prefix
            }
          }
        }
      }
    }
  }


  dynamic "service_connect_defaults" {
    for_each = length(var.ecs_cluster.cluster_service_connect_defaults) > 0 ? [var.ecs_cluster.cluster.cluster_service_connect_defaults] : []

    content {
      namespace = service_connect_defaults.value.namespace
    }
  }


  dynamic "setting" {
    for_each = flatten([var.ecs_cluster.cluster_settings])

    content {
      name  = setting.value.name
      value = setting.value.value
    }
  }

  tags = var.tags
}


########################################################################CloudWatch Log Group
########################################################################
resource "aws_cloudwatch_log_group" "this" {
  count = var.create && var.ecs_cluster.create_cloudwatch_log_group ? 1 : 0

  name = var.cloudwatch.log_group_name != null ? var.cloudwatch.log_group_name : "/aws/ecs/${var.ecs_cluster.cluster_name}"

  retention_in_days = var.cloudwatch.log_group_retention_in_days
  kms_key_id        = var.cloudwatch.log_group_kms_key_id

  tags = merge(var.tags, var.cloudwatch.log_group_tags)
}


################################################################################
# ECS Capacity Provider - EC2
################################################################################

resource "aws_ecs_capacity_provider" "this" {
  for_each = var.create ? var.capacity_provider.autoscaling_capacity_providers : {}

  name = each.value.name != "" ? each.value.name : each.key

  auto_scaling_group_provider {
    auto_scaling_group_arn = each.value.auto_scaling_group_arn

    # Enable managed termination protection only if managed scaling is defined
    managed_termination_protection = each.value.managed_scaling != null ? (each.value.managed_termination_protection != null ? each.value.managed_termination_protection : "DISABLED") : "DISABLED"

    dynamic "managed_scaling" {
      for_each = each.value.managed_scaling != null ? [each.value.managed_scaling] : []

      content {
        instance_warmup_period    = managed_scaling.value.instance_warmup_period
        maximum_scaling_step_size = managed_scaling.value.maximum_scaling_step_size
        minimum_scaling_step_size = managed_scaling.value.minimum_scaling_step_size
        status                    = managed_scaling.value.status
        target_capacity           = managed_scaling.value.target_capacity
      }
    }
  }

  tags = merge(var.tags, each.value.tags)
	depends_on = [aws_ecs_cluster.this]
}


################################################################################
# Cluster Capacity Providers
################################################################################

locals {
  default_capacity_providers = merge(
    { for k, v in var.capacity_provider.fargate_capacity_providers : k => v if var.capacity_provider.default_capacity_provider_use_fargate },
    { for k, v in var.capacity_provider.autoscaling_capacity_providers : k => v if !var.capacity_provider.default_capacity_provider_use_fargate }
  )
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  count = var.create && length(merge(var.capacity_provider.fargate_capacity_providers, var.capacity_provider.autoscaling_capacity_providers)) > 0 ? 1 : 0

  cluster_name = var.ecs_cluster.cluster_name

  capacity_providers = distinct(concat(
    [for k, v in var.capacity_provider.fargate_capacity_providers : try(v.name, k)],
    [for k, v in var.capacity_provider.autoscaling_capacity_providers : try(v.name, k)]
  ))

  dynamic "default_capacity_provider_strategy" {
    for_each = local.default_capacity_providers
    iterator = strategy

    content {
      capacity_provider = strategy.value.name
      base              = lookup(strategy.value, "base", null)  # Adjusted lookup
      weight            = lookup(strategy.value, "weight", null)
    }
  }

  depends_on = [aws_ecs_capacity_provider.this]
}


