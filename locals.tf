locals {
  ## cluster
  cluster_name = var.cluster_name_override != null ? var.cluster_name_override : "${var.namespace}-${var.environment}-ecs-fargate"
}
