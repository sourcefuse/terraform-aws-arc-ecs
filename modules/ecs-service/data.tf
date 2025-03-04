data "aws_region" "current" {}

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.ecs_service.cluster_name
}
