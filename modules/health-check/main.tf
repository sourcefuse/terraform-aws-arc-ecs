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
    #    cidr_blocks      = ["0.0.0.0/0"]
    #    ipv6_cidr_blocks = ["::/0"]
  }

  // TODO - remove if not needed
  #  egress {
  #    from_port        = 0
  #    protocol         = "-1"
  #    to_port          = 0
  #    cidr_blocks      = ["0.0.0.0/0"]
  #    ipv6_cidr_blocks = ["::/0"]
  #  }

  tags = merge(var.tags, tomap({
    Name = "${var.cluster_name}-health-check"
  }))
}

################################################################################
## iam
################################################################################
data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "health_check" {
  name               = "${var.cluster_name}-health-check"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = merge(var.tags, tomap({
    Name = "${var.cluster_name}-health-check"
  }))
}

// TODO - remove if not needed
#resource "aws_iam_role_policy_attachment" "aws_service_linked_role" {
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
#  role       = aws_iam_role.health_check.name
#}

################################################################################
## task definition
################################################################################
resource "aws_ecs_task_definition" "health_check" {
  family                   = "${var.cluster_name}-health-check"
  requires_compatibilities = var.task_definition_requires_compatibilities
  network_mode             = var.task_definition_network_mode
  cpu                      = var.task_definition_cpu
  memory                   = var.task_definition_memory
  task_role_arn            = aws_iam_role.health_check.arn
  execution_role_arn       = aws_iam_role.health_check.arn

  container_definitions = jsonencode([
    {
      name      = "${var.cluster_name}-health-check-nginx"
      image     = "nginx"
      cpu       = 100
      memory    = 100
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

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
  launch_type     = "FARGATE"
  desired_count   = 3

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
    path                = "/"
    unhealthy_threshold = "2"
  }

  tags = merge(var.tags, tomap({
    Name = "${var.cluster_name}-health-check"
  }))
}

################################################################################
## listeners
################################################################################
## http redirect
resource "aws_lb_listener" "http" {
  load_balancer_arn = var.lb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = merge(var.tags, tomap({
    Name = "${var.cluster_name}-http-redirect"
  }))
}

## https forward
resource "aws_lb_listener" "https" {
  load_balancer_arn = var.lb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.lb_ssl_policy
  certificate_arn   = var.lb_acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.health_check.arn
  }

  tags = merge(var.tags, tomap({
    Name = "${var.cluster_name}-https-forward"
  }))
}
