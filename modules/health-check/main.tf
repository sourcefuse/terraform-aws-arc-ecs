################################################################################
## defaults
################################################################################
terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

################################################################################
## security
################################################################################
resource "aws_security_group" "health_check" {
  name   = "${var.cluster_name}-health-check"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    protocol        = "tcp"
    to_port         = 80
    security_groups = var.lb_security_group_ids
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, tomap({
    Name = "${var.cluster_name}-health-check"
  }))
}

################################################################################
## task definition
################################################################################
## container definition
module "health_check" {
  source = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition?ref=0.58.2"

  container_name   = "${var.cluster_name}-health-check-nginx"
  container_image  = "nginx"
  container_memory = 100
  container_cpu    = 100
  essential        = true

  port_mappings = [
    {
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }
  ]
}

## task definition
resource "aws_ecs_task_definition" "health_check" {
  family                   = "${var.cluster_name}-health-check"
  requires_compatibilities = var.task_definition_requires_compatibilities
  network_mode             = var.task_definition_network_mode
  cpu                      = var.task_definition_cpu
  memory                   = var.task_definition_memory
  task_role_arn            = var.health_check_task_role_arn
  execution_role_arn       = var.task_execution_role_arn

  container_definitions = module.health_check.json_map_encoded_list

  tags = merge(var.tags, tomap({
    Name = "${var.cluster_name}-health-check"
  }))
}

################################################################################
## service
################################################################################
resource "aws_ecs_service" "health_check" {
  name            = "${var.cluster_name}-health-check"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.health_check.arn
  launch_type     = "FARGATE" # TODO - change this
  desired_count   = 3         # TODO - change this

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.health_check.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.health_check.arn
    container_name   = "${var.cluster_name}-health-check-nginx"
    container_port   = 80
  }

  tags = merge(var.tags, tomap({
    Name = "${var.cluster_name}-health-check"
  }))
}

################################################################################
## target group
################################################################################
resource "aws_lb_target_group" "health_check" {
  name        = "${var.cluster_name}-health-check"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    timeout             = "3"
    path                = var.health_check_path_pattern
    unhealthy_threshold = "2"
  }

  tags = merge(var.tags, tomap({
    Name = "${var.cluster_name}-health-check"
  }))
}

## create the forward rule
resource "aws_lb_listener_rule" "forward" {
  listener_arn = var.lb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.health_check.arn
  }

  condition {
    path_pattern {
      values = [var.health_check_path_pattern]
    }
  }

  tags = var.tags
}
