resource "aws_ecs_cluster" "cluster" {
  name = var.ecs.cluster_name
}

resource "aws_ecs_service" "service" {
  name            = local.service_name_full
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.definition.arn
  desired_count   = local.task.tasks_desired
  launch_type     = "FARGATE"

  force_new_deployment = true

  depends_on = [
    aws_security_group.ecs
  ]

  load_balancer {
    container_name   = local.service_name_full
    container_port   = local.task.container_port
    target_group_arn = aws_lb_target_group.tg.arn
  }

  network_configuration {
    subnets         = [for s in data.aws_subnet.private : s.id]
    security_groups = [aws_security_group.ecs.id]
  }
  tags = {
    Name        = "${var.ecs.service_name}-${var.environment}",
    Environment = "${var.environment}",
    Project     = "${var.project}",
    Service     = "${var.ecs.service_name_tag}"
  }
  propagate_tags = "TASK_DEFINITION"
}

resource "aws_ecs_task_definition" "definition" {
  family                   = local.service_name_full
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.task.container_vcpu
  memory                   = local.task.container_memory
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = aws_iam_role.execution_role.arn

  container_definitions = templatefile(local.task.container_definition, {
    alb_port          = local.alb.listener_port,
    aws_region        = var.aws_region,
    cluster_name_full = local.cluster_name_full,
    container_port    = local.task.container_port,
    environment       = var.environment,
    environment_vars  = jsonencode(local.environment_variables),
    repository_name   = var.ecs.repository_name,
    service_name_full = local.service_name_full,
    cluster_name      = var.ecs.cluster_name,
    service_name      = var.ecs.service_name
  })

  tags = {
    Name        = "${var.ecs.service_name}-${var.environment}-task-definition",
    Environment = "${var.environment}",
    Project     = "${var.project}",
    Service     = "${var.ecs.service_name_tag}"
  }
}
