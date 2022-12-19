################################################################################
## defaults
################################################################################
terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.30"
    }
  }
}

################################################################################
## lookups
################################################################################
data "aws_region" "current" {}

################################################################################
## cloudwatch
################################################################################
resource "aws_cloudwatch_log_group" "this" {
  count = length(var.log_configuration) > 0 ? 0 : 1

  name              = "/ecs/${var.service}/${var.name}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = var.tags
}
