data "aws_region" "current" {}

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.ecs_service.cluster_name
}

data "aws_lb_target_group" "ecs_target_group" {
  name = var.ecs_service.aws_lb_target_group_name
}
