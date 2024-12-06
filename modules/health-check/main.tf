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

provider "aws" {
  region = data.aws_region.current
}

/* module "ecs_cluster" {
  source = "../ecs"

  ecs_cluster = {
    cluster_name = "healthcheck-poc-cluster"
  }

  capacity_provider = {
    default_capacity_provider_use_fargate = true
  }
  cloudwatch = {}

} */

resource "aws_ecs_service" "this" {
  name            = local.service_name_full
  cluster         = data.aws_ecs_cluster.cluster
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.task.tasks_desired
  launch_type     = "FARGATE"

  force_new_deployment = true

  dynamic "load_balancer" {
    for_each = var.ecs.enable_load_balancer ? [1] : []

    content {
      container_name   = var.ecs.cluster_name
      container_port   = var.task.container_port
      target_group_arn = var.ecs.aws_lb_target_group_arn
    }
  }

  network_configuration {
    subnets         = [for s in data.aws_subnet.private : s.id]
    security_groups = [aws_security_group.ecs.id]
  }
  propagate_tags = "TASK_DEFINITION"

  depends_on = [
    aws_security_group.ecs
  ]
}

resource "aws_ecs_task_definition" "this" {
  family                   = local.service_name_full
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task.container_vcpu
  memory                   = var.task.container_memory
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = aws_iam_role.execution_role.arn

  container_definitions = templatefile(var.task.container_definition, {
    alb_port          = var.alb.listener_port,
    aws_region        = data.aws_region.current,
    cluster_name_full = local.cluster_name_full,
    container_port    = var.task.container_port,
    environment       = var.environment,
    environment_vars  = jsonencode(local.environment_variables),
    repository_name   = var.ecs.repository_name,
    service_name_full = local.service_name_full,
    cluster_name      = var.ecs.cluster_name,
    service_name      = var.ecs.service_name
  })
}


resource "aws_security_group" "ecs" {
  name        = local.security_group_name
  description = "Allow traffic from the ALB into the Docker containers."
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description     = "Allow inbound proxy traffic"
    from_port       = var.task.container_port
    to_port         = var.task.container_port
    protocol        = "tcp"
    cidr_blocks     = [for s in data.aws_subnet.private : s.cidr_block]
    #security_groups = [data.aws_security_group.alb_sg]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
