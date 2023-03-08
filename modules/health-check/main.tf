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
resource "aws_security_group" "this" {
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
  source = "git::https://github.com/aws-ia/ecs-blueprints.git//modules/ecs-container-definition?ref=5a80841ac6f2436941c45e7a9cd9b69407b9ab32"

  name = "${var.cluster_name}-health-check"
  #  image     = "nginx"  # TODO - remove if not needed
  image   = "ealen/echo-server"
  service = "health-check"
  #  memory    = 100  # TODO - remove if not needed
  #  cpu       = 100  # TODO - remove if not needed
  essential = true

  port_mappings = [
    {
      containerPort = 80
      hostPort      = 80
    }
  ]
}

################################################################################
## service
################################################################################
resource "aws_ecs_service" "this" {
  name    = "${var.cluster_name}-health-check"
  cluster = var.cluster_id

  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE" # TODO - change this
  desired_count   = 1         # TODO - change this

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.this.id]
    assign_public_ip = false
  }

  load_balancer {
    container_name   = "${var.cluster_name}-health-check"
    target_group_arn = aws_lb_target_group.this.arn
    container_port   = 80
  }

  tags = merge(var.tags, tomap({
    Name = "${var.cluster_name}-health-check"
  }))
}

################################################################################
## target group
################################################################################
resource "aws_lb_target_group" "this" {
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
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    path_pattern {
      values = [var.health_check_path_pattern]
    }
  }

  tags = var.tags
}

## task definition
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.cluster_name}-health-check"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_definition_cpu
  memory                   = var.task_definition_memory

  task_role_arn      = aws_iam_role.task.arn
  execution_role_arn = var.task_execution_role_arn # aws_iam_role.health_check_ecs_role.arn

  container_definitions = jsonencode([module.health_check.container_definition])

  tags = merge(var.tags, tomap({
    Name = "${var.cluster_name}-health-check"
  }))
}

################################################################################
## route 53
################################################################################
resource "aws_route53_record" "this" {
  for_each = toset(var.health_check_route_53_records)

  zone_id = data.aws_route53_zone.this.id
  name    = each.value
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }

  lifecycle {
    create_before_destroy = false
  }
}
