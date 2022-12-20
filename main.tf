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

data "aws_route53_zone" "health_check_zone" {
  name = var.health_check_route53_zone
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

  access_logs_enabled = true
  // TODO - change to variable
  alb_access_logs_s3_bucket_force_destroy = false
  // TODO - change to variable
  alb_access_logs_s3_bucket_force_destroy_enabled = false
  // TODO - change to variable
  acm_certificate_arn = var.alb_acm_certificate_arn
  internal            = var.alb_internal
  idle_timeout        = var.alb_idle_timeout

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

################################################################################
## ecs cluster
################################################################################
module "ecs" {
  source       = "git@github.com:terraform-aws-modules/terraform-aws-ecs?ref=v4.1.2"
  cluster_name = local.cluster_name

  #  fargate_capacity_providers = var.fargate_capacity_providers


  tags = merge(var.tags, tomap({
    Name = local.cluster_name
  }))
}

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
  name = "${module.ecs.cluster_name}-hc"

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
}

resource "aws_iam_role_policy_attachment" "aws_service_linked_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  role       = aws_iam_role.health_check_ecs_role.name
}

################################################################################
## ecs task definition
################################################################################
resource "aws_ecs_task_definition" "health_check_task_definition" {
  family                   = "health-check-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  task_role_arn            = aws_iam_role.health_check_ecs_role.arn
  execution_role_arn       = aws_iam_role.health_check_ecs_role.arn
  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx"
      cpu       = 10
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
}

resource "aws_security_group" "ecs_task_sg" {
  vpc_id = var.vpc_id
  name   = "ecs_task_sg"
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
}

################################################################################
## ecs service
################################################################################
resource "aws_ecs_service" "health_check_service" {
  name            = "health-check-service"
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
    container_name   = "nginx"
    container_port   = 80
  }
}


resource "aws_lb_target_group" "health_check_target_group" {
  name        = "health-check-target-group"
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
}

resource "aws_lb_listener" "https_default" {
  load_balancer_arn = module.alb.alb_arn
  port              = "443"
  protocol          = "HTTPS"
  // TODO: update to stricter policy
  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.alb_acm_certificate_arn


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.health_check_target_group.arn
  }
}

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

  tags = var.tags
}

################################################################################
## cloudwatch
################################################################################
## iam policy
#data "aws_iam_policy_document" "cloudwatch_loggroup_kms" {
#  version = "2012-10-17"
#
#  ## allow ec2 access to the key
#  statement {
#    effect = "Allow"
#
#    actions = [
#      "kms:Encrypt*",
#      "kms:Decrypt*",
#      "kms:ReEncrypt*",
#      "kms:GenerateDataKey*",
#      "kms:Describe*"
#    ]
#
#    resources = ["*"]
#
#    principals {
#      type        = "Service"
#      identifiers = [
#        "cloudwatch.amazonaws.com",
#        "ec2.amazonaws.com",
#        "logs.${var.region}.amazonaws.com"
#      ]
#    }
#  }
#
#  ## allow administration of the key
#  dynamic "statement" {
#    for_each = toset(sort(var.kms_admin_iam_role_identifier_arns))
#
#    content {
#      effect = "Allow"
#
#      // * is required to avoid this error from the API - MalformedPolicyDocumentException: The new key policy will not allow you to update the key policy in the future.
#      actions = ["kms:*"]
#
#      // * is required to avoid this error from the API - MalformedPolicyDocumentException: The new key policy will not allow you to update the key policy in the future.
#      resources = ["*"]
#
#      principals {
#        type        = "AWS"
#        identifiers = [statement.value]
#      }
#    }
#  }
#}

## kms
#module "cloudwatch_kms" {
#  source = "git::https://github.com/cloudposse/terraform-aws-kms-key?ref=0.12.1"
#
#  name                    = local.cloudwatch_kms_key_name
#  description             = "KMS key for CloudWatch Log Group."
#  label_key_case          = "lower"
#  multi_region            = false
#  deletion_window_in_days = 7
#  enable_key_rotation     = true
#  alias                   = "alias/${var.namespace}/${var.environment}/${local.cloudwatch_kms_key_name}"
#  policy                  = data.aws_iam_policy_document.cloudwatch_loggroup_kms.json
#
#  tags = var.tags
#}
#
### log group
#resource "aws_cloudwatch_log_group" "this" {
#  name              = local.cloudwatch_log_group_name
#  kms_key_id        = module.cloudwatch_kms.key_arn
#  retention_in_days = var.cloudwatch_log_group_retention_days
#
#  tags = merge(var.tags, tomap({
#    Name = local.cloudwatch_log_group_name
#  }))
#}
