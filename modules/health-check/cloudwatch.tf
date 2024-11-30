resource "aws_cloudwatch_log_group" "proxy" {
  name              = "/aws/ecs/${var.ecs.cluster_name}/${var.ecs.service_name}/${var.environment}"
  retention_in_days = 90
  tags = {
    Name        = "/aws/ecs/${var.ecs.cluster_name}/${var.ecs.service_name}/${var.environment}",
    Environment = "${var.environment}",
    Project     = "${var.project}",
    Service     = "${var.ecs.service_name_tag}"
  }
}


// Autoscaling - Alarm CPU High
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${local.service_name_full}-cpu-high-alarm"
  comparison_operator = local.autoscaling.scale_up.comparison_operator
  evaluation_periods  = local.autoscaling.scale_up.evaluation_periods
  metric_name         = local.autoscaling.metric_name
  namespace           = local.autoscaling.namespace
  period              = local.autoscaling.scale_up.period
  statistic           = local.autoscaling.scale_up.statistic
  threshold           = local.autoscaling.scale_up.threshold

  dimensions = local.autoscaling.dimensions

  alarm_actions = [aws_appautoscaling_policy.scale_up.arn]
  tags = {
    Name        = "${local.service_name_full}-cpu-high-alarm",
    Environment = "${var.environment}",
    Project     = "${var.project}",
    Service     = "${var.ecs.service_name_tag}"
  }
}

// Autoscaling - Alarm CPU Low
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${local.service_name_full}-cpu-low-alarm"
  comparison_operator = local.autoscaling.scale_down.comparison_operator
  evaluation_periods  = local.autoscaling.scale_down.evaluation_periods
  metric_name         = local.autoscaling.metric_name
  namespace           = local.autoscaling.namespace
  period              = local.autoscaling.scale_down.period
  statistic           = local.autoscaling.scale_down.statistic
  threshold           = local.autoscaling.scale_down.threshold

  dimensions = local.autoscaling.dimensions

  alarm_actions = [aws_appautoscaling_policy.scale_down.arn]
  tags = {
    Name        = "${local.service_name_full}-cpu-low-alarm",
    Environment = "${var.environment}",
    Project     = "${var.project}",
    Service     = "${var.ecs.service_name_tag}"
  }
}