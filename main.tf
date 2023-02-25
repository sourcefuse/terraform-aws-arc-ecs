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
## ecs cluster
################################################################################
module "ecs" {
  source       = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs?ref=v4.1.2"
  cluster_name = local.cluster_name

  tags = merge(var.tags, tomap({
    Name = local.cluster_name
  }))
}

################################################################################
## iam
################################################################################
data "aws_iam_policy_document" "assume_role_policy" {
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

// TODO: clean up and split task execution role from task role
resource "aws_iam_role" "health_check_ecs_role" {
  name = "${module.ecs.cluster_name}-health-check"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  inline_policy {
    name = "admin_policy_that_needs_to_go"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = "*"
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  tags = merge(var.tags, tomap({
    Name = "${module.ecs.cluster_name}-health-check"
  }))
}

resource "aws_iam_role_policy_attachment" "aws_service_linked_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  role       = aws_iam_role.health_check_ecs_role.name
}

################################################################################
## ecs task definition
################################################################################
resource "aws_ecs_task_definition" "health_check_task_definition" {
  family                   = "${module.ecs.cluster_name}-health-check"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024 // TODO - change to variable
  memory                   = 2048 // TODO - change to variable
  task_role_arn            = aws_iam_role.health_check_ecs_role.arn
  execution_role_arn       = aws_iam_role.health_check_ecs_role.arn

  container_definitions = jsonencode([
    {
      name      = "${module.ecs.cluster_name}-health-check-nginx"
      image     = "nginx"
      cpu       = 100
      memory    = 512
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
    Name = "${module.ecs.cluster_name}-health-check"
  }))
}

################################################################################
## security
################################################################################
resource "aws_security_group" "ecs_task_sg" {
  vpc_id = var.vpc_id
  name   = "${module.ecs.cluster_name}-ecs-task-sg"

  ingress {
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, tomap({
    Name = "${module.ecs.cluster_name}-ecs-task-sg"
  }))
}

################################################################################
## ecs service
################################################################################
resource "aws_ecs_service" "health_check_service" {
  name            = "${module.ecs.cluster_name}-health-check"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.health_check_task_definition.arn
  launch_type     = "FARGATE"
  desired_count   = 3

  network_configuration {
    subnets          = var.task_subnet_ids
    security_groups  = [aws_security_group.ecs_task_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.health_check_target_group.arn
    container_name   = "${module.ecs.cluster_name}-health-check-nginx"
    container_port   = 80
  }

  tags = merge(var.tags, tomap({
    Name = "${module.ecs.cluster_name}-health-check"
  }))
}

################################################################################
## load balancer
################################################################################
module "alb" {
  source = "./modules/alb"

  namespace          = var.namespace
  environment        = var.environment
  vpc_id             = var.vpc_id
  subnet_ids         = var.alb_subnets_ids
  security_group_ids = [aws_security_group.ecs_task_sg.id]

  access_logs_enabled                             = true  // TODO - change to variable
  alb_access_logs_s3_bucket_force_destroy         = false // TODO - change to variable
  alb_access_logs_s3_bucket_force_destroy_enabled = false // TODO - change to variable
  internal                                        = var.alb_internal
  idle_timeout                                    = var.alb_idle_timeout

  // TODO - change to variable
  http_ingress_cidr_blocks = [
    "0.0.0.0/0"
  ]

  // TODO - change to variable
  https_ingress_cidr_blocks = [
    "0.0.0.0/0"
  ]

  tags = var.tags
}

## target group
resource "aws_lb_target_group" "health_check_target_group" {
  name        = "${module.ecs.cluster_name}-hc"
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
    Name = "${module.ecs.cluster_name}-hc"
  }))
}

## https forward
resource "aws_lb_listener" "https_default" {
  load_balancer_arn = module.alb.alb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.alb_ssl_policy
  certificate_arn   = var.alb_acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.health_check_target_group.arn
  }

  tags = merge(var.tags, tomap({
    Name = "${module.ecs.cluster_name}-https-forward"
  }))
}

## http redirect
resource "aws_lb_listener" "http" {
  load_balancer_arn = module.alb.alb_arn
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
    Name = "${module.ecs.cluster_name}-http-redirect"
  }))
}
