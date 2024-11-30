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

module "ecs_cluster" {
    source = "../ecs"

    ecs_cluster = {
      cluster_name = "healthcheck-poc-cluster"
    }

    capacity_provider = {
      default_capacity_provider_use_fargate = true
    }
    cloudwatch =  {}
    
}
resource "aws_ecs_service" "service" {
  name            = local.service_name_full
  cluster         = module.ecs_cluster.ecs_cluster_id
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
}


resource "aws_security_group" "ecs" {
  name        = local.security_group_name
  description = "Allow traffic from the ALB into the Docker containers."
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description     = "Allow inbound proxy traffic"
    from_port       = local.task.container_port
    to_port         = local.task.container_port
    protocol        = "tcp"
    cidr_blocks     = [for s in data.aws_subnet.private : s.cidr_block]
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}