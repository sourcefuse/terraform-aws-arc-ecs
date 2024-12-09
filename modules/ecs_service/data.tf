data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_region" "current" {}

data "aws_subnets" "private" {

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name = "tag:Name"

    values = [
      "*private*",
    ]
  }
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.ecs_service.cluster_name
}

data "aws_lb_target_group" "ecs_target_group" {
  name = var.ecs_service.aws_lb_target_group_name
}
