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
## ecs
################################################################################
module "ecs" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-ecs?ref=v4.1.2"

  cluster_name = local.cluster_name

  fargate_capacity_providers     = var.fargate_capacity_providers
  autoscaling_capacity_providers = var.autoscaling_capacity_providers

  cluster_configuration = {
    execute_command_configuration = {
      kms_key_id = data.aws_iam_policy_document.cloudwatch_loggroup_kms.json
      logging    = "OVERRIDE"

      log_configuration = {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.this.name
      }
    }
  }

  tags = merge(var.tags, tomap({
    Name = local.cluster_name
  }))
}

################################################################################
## cloudwatch
################################################################################
## iam policy
data "aws_iam_policy_document" "cloudwatch_loggroup_kms" {
  version = "2012-10-17"

  ## allow ec2 access to the key
  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    resources = ["*"]

    principals {
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com",
        "ec2.amazonaws.com",
        "logs.${var.region}.amazonaws.com"
      ]
    }
  }

  ## allow administration of the key
  dynamic "statement" {
    for_each = toset(sort(var.kms_admin_iam_role_identifier_arns))

    content {
      effect = "Allow"

      // * is required to avoid this error from the API - MalformedPolicyDocumentException: The new key policy will not allow you to update the key policy in the future.
      actions = ["kms:*"]

      // * is required to avoid this error from the API - MalformedPolicyDocumentException: The new key policy will not allow you to update the key policy in the future.
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = [statement.value]
      }
    }
  }
}

## kms
module "cloudwatch_kms" {
  source = "git::https://github.com/cloudposse/terraform-aws-kms-key?ref=0.12.1"

  name                    = local.cloudwatch_kms_key_name
  description             = "KMS key for CloudWatch Log Group."
  label_key_case          = "lower"
  multi_region            = false
  deletion_window_in_days = 7
  enable_key_rotation     = true
  alias                   = "alias/${var.namespace}/${var.environment}/${local.cloudwatch_kms_key_name}"
  policy                  = data.aws_iam_policy_document.cloudwatch_loggroup_kms.json

  tags = var.tags
}

## log group
resource "aws_cloudwatch_log_group" "this" {
  name              = local.cloudwatch_log_group_name
  kms_key_id        = module.cloudwatch_kms.key_arn
  retention_in_days = var.cloudwatch_log_group_retention_days

  tags = merge(var.tags, tomap({
    Name = local.cloudwatch_log_group_name
  }))
}
