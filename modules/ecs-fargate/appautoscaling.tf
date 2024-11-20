resource "aws_appautoscaling_policy" "scale_up" {
  name               = "${local.service_name_full}-scale-up-policy"
  depends_on         = [aws_appautoscaling_target.scale_target]
  service_namespace  = "ecs"
  resource_id        = "service/${local.cluster_name_full}/${local.service_name_full}"
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = local.autoscaling.scale_up.cooldown
    metric_aggregation_type = "Maximum"

    dynamic "step_adjustment" {
      for_each = local.autoscaling.scale_up.step_adjustment
      iterator = k

      content {
        metric_interval_lower_bound = lookup(k.value, "metric_interval_lower_bound", null)
        metric_interval_upper_bound = lookup(k.value, "metric_interval_upper_bound", null)
        scaling_adjustment          = k.value["scaling_adjustment"]
      }
    }
  }
}

resource "aws_appautoscaling_policy" "scale_down" {
  name               = "${local.service_name_full}-scale-down-policy"
  depends_on         = [aws_appautoscaling_target.scale_target]
  service_namespace  = "ecs"
  resource_id        = "service/${local.cluster_name_full}/${local.service_name_full}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = local.autoscaling.scale_down.cooldown
    metric_aggregation_type = "Maximum"

    dynamic "step_adjustment" {
      for_each = local.autoscaling.scale_down.step_adjustment
      iterator = k

      content {
        metric_interval_lower_bound = lookup(k.value, "metric_interval_lower_bound", null)
        metric_interval_upper_bound = lookup(k.value, "metric_interval_upper_bound", null)
        scaling_adjustment          = k.value["scaling_adjustment"]
      }
    }
  }
}

resource "aws_appautoscaling_target" "scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${local.cluster_name_full}/${local.service_name_full}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = local.autoscaling.minimum_capacity
  max_capacity       = local.autoscaling.maximum_capacity
}
