data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_region" "current" {}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Type = "private"
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
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