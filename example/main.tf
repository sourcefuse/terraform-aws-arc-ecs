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

module "tags" {
  source = "git@github.com:sourcefuse/terraform-aws-refarch-tags?ref=1.0.2"

  environment = var.environment
  project     = "Example"

  extra_tags = {
    RepoName = "terraform-aws-refarch-ecs"
    Example  = "true"
  }
}

provider "aws" {
  region = var.region
}

################################################################################
## lookups
################################################################################
data "aws_ami" "this" {
  owners      = var.ami_owners
  most_recent = "true"

  dynamic "filter" {
    for_each = var.ami_filter

    content {
      name   = filter.key
      values = filter.value
    }
  }
}

################################################################################
## autoscaling
################################################################################
resource "aws_launch_template" "this" {
  name_prefix   = "example-"
  image_id      = data.aws_ami.this.image_id
  instance_type = "t3.medium"

  tags = merge(module.tags.tags, tomap({
    NamePrefix = "example-"
  }))
}

resource "aws_autoscaling_group" "this" {
  name_prefix        = "example-"
  availability_zones = ["us-east-1a", "us-east-1b"]
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1

  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  protect_from_scale_in     = true

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(module.tags.tags, tomap({
      NamePrefix = "example-"
    }))

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

################################################################################
## ecs
################################################################################
module "ecs" {
  source = "../"

  environment = var.environment
  namespace   = var.namespace
  region      = var.region

  kms_admin_iam_role_identifier_arns = var.kms_admin_iam_role_identifier_arns

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  autoscaling_capacity_providers = {
    one = {
      auto_scaling_group_arn         = aws_autoscaling_group.this.arn
      managed_termination_protection = "DISABLED" //"ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 5
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 60
      }

      default_capacity_provider_strategy = {
        weight = 60
        base   = 20
      }
    }
  }

  tags = module.tags.tags
}
