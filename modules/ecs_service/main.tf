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

resource "aws_ecs_service" "this" {
  name            = local.service_name_full
  cluster         = data.aws_ecs_cluster.cluster.cluster_name
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.task.tasks_desired
  launch_type     = "EC2"

  force_new_deployment = true

  dynamic "load_balancer" {
    for_each = var.ecs_service.enable_load_balancer ? [1] : []

    content {
      container_name   = var.ecs_service.cluster_name
      container_port   = var.task.container_port
      target_group_arn = data.aws_lb_target_group.ecs_target_group.arn
    }
  }

  network_configuration {
    subnets         = var.ecs_service.ecs_subnets
    security_groups = [aws_security_group.ecs.id]
  }
  propagate_tags = "TASK_DEFINITION"

  depends_on = [
    aws_security_group.ecs,
    aws_ecs_task_definition.this
  ]
}

resource "aws_ecs_task_definition" "this" {
  family                   = local.service_name_full
  network_mode             = var.task.network_mode
  requires_compatibilities = ["EC2"]
  cpu                      = var.task.container_vcpu
  memory                   = var.task.container_memory
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = aws_iam_role.execution_role.arn

  container_definitions = templatefile(var.task.container_definition, {
    alb_port          = var.lb.listener_port,
    aws_region        = data.aws_region.current.name,
    cluster_name_full = local.cluster_name_full,
    container_port    = var.task.container_port,
    environment       = var.environment,
    environment_vars  = jsonencode(local.environment_variables),
    secrets           = jsonencode(local.secrets)
    repository_name   = var.ecs_service.repository_name,
    service_name_full = local.service_name_full,
    cluster_name      = var.ecs_service.cluster_name,
    service_name      = var.ecs_service.service_name,
    log_group_name    = aws_cloudwatch_log_group.this.name
  })
}


resource "aws_security_group" "ecs" {
  name        = local.security_group_name
  description = "Allow traffic from the ALB into the Docker containers."
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow inbound proxy traffic"
    from_port       = var.task.container_port
    to_port         = var.task.container_port
    protocol        = "tcp"
    security_groups = [var.lb.security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
