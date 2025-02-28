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

########################################################################
# CloudWatch Log Group
########################################################################
resource "aws_cloudwatch_log_group" "this" {
  count = var.ecs_cluster.create_cloudwatch_log_group ? 1 : 0

  name = var.ecs_cluster.configuration.execute_command_configuration.log_configuration.log_group_name != null ? var.ecs_cluster.configuration.execute_command_configuration.log_configuration.log_group_name : "/aws/ecs/${var.ecs_cluster.name}"

  retention_in_days = var.ecs_cluster.configuration.execute_command_configuration.log_configuration.log_group_retention_in_days
  kms_key_id        = var.ecs_cluster.configuration.execute_command_configuration.log_configuration.log_group_kms_key_id

  tags = merge(var.tags, var.ecs_cluster.configuration.execute_command_configuration.log_configuration.log_group_tags)
}


########################################################################
# ECS Cluster
########################################################################
resource "aws_ecs_cluster" "this" {

  name = var.ecs_cluster.name

  dynamic "configuration" {
    for_each = var.ecs_cluster.configuration != null ? { "default" = var.ecs_cluster.configuration } : {}

    content {
      dynamic "execute_command_configuration" {
        for_each = length(configuration.value.execute_command_configuration) > 0 ? [configuration.value.execute_command_configuration] : []

        content {
          kms_key_id = length(execute_command_configuration.value.kms_key_id) > 0 ? execute_command_configuration.value.kms_key_id : ""
          logging    = length(execute_command_configuration.value.logging) > 0 ? execute_command_configuration.value.logging : "DEFAULT"

          dynamic "log_configuration" {
            for_each = var.ecs_cluster.create_cloudwatch_log_group && length(execute_command_configuration.value.log_configuration) > 0 ? [execute_command_configuration.value.log_configuration] : []

            content {
              cloud_watch_encryption_enabled = log_configuration.value.cloudwatch_encryption_enabled
              cloud_watch_log_group_name     = log_configuration.value.log_group_name
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
    for_each = length(var.ecs_cluster.service_connect_defaults) > 0 ? [var.ecs_cluster.cluster.service_connect_defaults] : []

    content {
      namespace = service_connect_defaults.value.namespace
    }
  }

  dynamic "setting" {
    for_each = flatten([var.ecs_cluster.settings])

    content {
      name  = setting.value.name
      value = setting.value.value
    }
  }

  tags = merge(var.tags, var.ecs_cluster.tags)
}

################################################################################
# EC2 Launch Template
################################################################################

resource "aws_launch_template" "this" {
  count = var.capacity_provider.use_fargate != true ? 1 : 0

  name = var.launch_template.name

  dynamic "block_device_mappings" {
    for_each = var.launch_template.block_device_mappings
    content {
      device_name = block_device_mappings.value.device_name

      dynamic "ebs" {
        for_each = block_device_mappings.value.ebs != null ? [block_device_mappings.value.ebs] : []
        content {
          volume_size = ebs.value.volume_size
        }
      }
    }
  }

  dynamic "cpu_options" {
    for_each = var.launch_template.cpu_options != null ? [var.launch_template.cpu_options] : []
    content {
      core_count       = cpu_options.value.core_count
      threads_per_core = cpu_options.value.threads_per_core
    }
  }

  disable_api_stop        = var.launch_template.disable_api_stop
  disable_api_termination = var.launch_template.disable_api_termination
  ebs_optimized           = var.launch_template.ebs_optimized

  dynamic "elastic_gpu_specifications" {
    for_each = var.launch_template.elastic_gpu_specifications
    content {
      type = elastic_gpu_specifications.value.type
    }
  }

  dynamic "iam_instance_profile" {
    for_each = var.launch_template.iam_instance_profile != null ? [var.launch_template.iam_instance_profile] : []
    content {
      name = iam_instance_profile.value.name
    }
  }

  image_id      = var.launch_template.image_id
  instance_type = var.launch_template.instance_type

  instance_initiated_shutdown_behavior = var.launch_template.instance_initiated_shutdown_behavior

  dynamic "monitoring" {
    for_each = var.launch_template.monitoring != null ? [var.launch_template.monitoring] : []
    content {
      enabled = monitoring.value.enabled
    }
  }

  dynamic "network_interfaces" {
    for_each = var.launch_template.network_interfaces
    content {
      associate_public_ip_address = network_interfaces.value.associate_public_ip_address
      ipv4_prefixes               = network_interfaces.value.ipv4_prefixes
      ipv6_prefixes               = network_interfaces.value.ipv6_prefixes
      ipv4_addresses              = network_interfaces.value.ipv4_addresses
      ipv6_addresses              = network_interfaces.value.ipv6_addresses
      network_interface_id        = network_interfaces.value.network_interface_id
      private_ip_address          = network_interfaces.value.private_ip_address
      security_groups             = network_interfaces.value.security_groups
      subnet_id                   = network_interfaces.value.subnet_id
    }
  }

  dynamic "placement" {
    for_each = var.launch_template.placement != null ? [var.launch_template.placement] : []
    content {
      availability_zone = placement.value.availability_zone
    }
  }

  vpc_security_group_ids = var.launch_template.vpc_security_group_ids

  dynamic "tag_specifications" {
    for_each = var.launch_template.tag_specifications
    content {
      resource_type = tag_specifications.value.resource_type
      tags          = tag_specifications.value.tags
    }
  }

  user_data = var.launch_template.user_data != null ? filebase64(var.launch_template.user_data) : null

  tags = var.tags
}

################################################################################
# Auto Scaling Group
################################################################################

resource "aws_autoscaling_group" "this" {
  count = var.capacity_provider.use_fargate != true ? 1 : 0

  name                = var.asg.name != null ? var.asg.name : "ecs-auto-scaling-group"
  min_size            = var.asg.min_size
  max_size            = var.asg.max_size
  desired_capacity    = var.asg.desired_capacity != null ? var.asg.desired_capacity : var.asg.min_size
  vpc_zone_identifier = var.asg.vpc_zone_identifier != null ? var.asg.vpc_zone_identifier : []

  launch_template {
    id      = aws_launch_template.this[0].id
    version = "$Latest"
  }

  health_check_type         = var.asg.health_check_type != null ? var.asg.health_check_type : "EC2"
  health_check_grace_period = var.asg.health_check_grace_period != null ? var.asg.health_check_grace_period : 300
  protect_from_scale_in     = var.asg.protect_from_scale_in != null ? var.asg.protect_from_scale_in : false
  default_cooldown          = var.asg.default_cooldown != null ? var.asg.default_cooldown : 300

  instance_refresh {
    strategy = var.asg.instance_refresh.strategy
    preferences {
      min_healthy_percentage = var.asg.instance_refresh.preferences != null && var.asg.instance_refresh.preferences.min_healthy_percentage != null ? var.asg.instance_refresh.preferences.min_healthy_percentage : 50
    }
  }
}
################################################################################
# ECS Capacity Provider - EC2
################################################################################

resource "aws_ecs_capacity_provider" "this" {
  for_each = (var.capacity_provider.use_fargate != true && var.capacity_provider.autoscaling_capacity_providers != null) ? var.capacity_provider.autoscaling_capacity_providers : {}

  name = each.value.name != "" ? each.value.name : each.key

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.this[0].arn

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

  tags       = merge(var.tags, each.value.tags)
  depends_on = [aws_ecs_cluster.this]
}


################################################################################
# Cluster Capacity Providers
################################################################################

locals {
  default_capacity_providers = merge(
    { for k, v in var.capacity_provider.fargate_capacity_providers : k => v if var.capacity_provider.use_fargate },
    { for k, v in var.capacity_provider.autoscaling_capacity_providers : k => v if !var.capacity_provider.use_fargate }
  )
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  count = length(merge(var.capacity_provider.fargate_capacity_providers, var.capacity_provider.autoscaling_capacity_providers)) > 0 ? 1 : 0

  cluster_name = var.ecs_cluster.name

  capacity_providers = distinct(concat(
    [for k, v in var.capacity_provider.fargate_capacity_providers : try(v.name, k)],
    [for k, v in var.capacity_provider.autoscaling_capacity_providers : try(v.name, k)]
  ))

  dynamic "default_capacity_provider_strategy" {
    for_each = local.default_capacity_providers
    iterator = strategy

    content {
      capacity_provider = strategy.value.name
      base              = lookup(strategy.value, "base", null)
      weight            = lookup(strategy.value, "weight", null)
    }
  }
  depends_on = [aws_ecs_capacity_provider.this]
}
