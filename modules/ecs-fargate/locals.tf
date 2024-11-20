locals {
  service_name_full       = "${var.ecs.service_name}-${var.environment}"
  cluster_name_full       = "${var.ecs.cluster_name}-${var.environment}"
  
  region_code = (var.aws_region == "us-west-1") ? "uw1" : "ue1"

  task = defaults(var.task, {
    tasks_desired        = 2
    container_vcpu       = 512
    container_memory     = 1024
    container_definition = "${path.module}/json/container_definition.json.tftpl"
    task_execution_role  = "${path.module}/json/execution_role.json"
  })

  alb = defaults(var.alb, {
    deregistration_delay = 300
  })

  environment_variables = [for name, value in local.task.environment_variables : {
    Name  = name
    Value = value
  }]

  autoscaling = defaults(var.autoscaling, {
    namespace = "AWS/ECS"
    scale_up = {
      evaluation_periods  = "3"
      period              = "60"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      statistic           = "Maximum"

    }
    scale_down = {
      evaluation_periods  = "3"
      period              = "60"
      comparison_operator = "LessThanThreshold"
      statistic           = "Average"

    }
    metric_name = "CPUUtilization"
  })
}
