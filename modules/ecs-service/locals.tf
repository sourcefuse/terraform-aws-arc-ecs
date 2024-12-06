locals {
  service_name_full = "${var.ecs.service_name}-${var.environment}"
  cluster_name_full = "${var.ecs.cluster_name}-${var.environment}"

  security_group_name = "${var.ecs.service_name}-${var.environment}-ecs"

  task = {
    container_definition  = coalesce(var.task.container_definition, "${path.module}/json/container_definition.json.tftpl")
    task_execution_role   = coalesce(var.task.task_execution_role, "${path.module}/json/execution_role.json")
    environment_variables = coalesce(var.task.environment_variables, {})
  }

  alb = {
    deregistration_delay = coalesce(var.alb.deregistration_delay, 300)
  }

  environment_variables = [for name, value in local.task.environment_variables : {
    Name  = name
    Value = value
  }]

  /* private_subnets = [
    for s in data.aws_subnet.private :
    s.id if lookup(s.tags, "Type", "") == "private"
  ] */

}