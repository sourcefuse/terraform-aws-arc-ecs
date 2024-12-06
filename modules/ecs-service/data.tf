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

data "aws_lb" "service" {
  name = var.alb.name
}

data "aws_security_group" "alb_sg" {
  id = var.alb.security_group_id
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.ecs.cluster_name
}

data "aws_lb_target_group" "ecs_target_group" {
  name = var.ecs.aws_lb_target_group_name
}