locals {
  ## cluster
  cluster_name = var.cluster_name_override != null ? var.cluster_name_override : "${var.namespace}-${var.environment}-ecs-fargate"

  ## cloudwatch
  cloudwatch_log_group_name = var.cloudwatch_log_group_name_override != null ? var.cloudwatch_log_group_name_override : "/aws/ecs/${local.cluster_name}"
  cloudwatch_kms_key_name   = var.cloudwatch_kms_key_name_override != null ? var.cloudwatch_kms_key_name_override : "${local.cluster_name}-cw-lg"
}
