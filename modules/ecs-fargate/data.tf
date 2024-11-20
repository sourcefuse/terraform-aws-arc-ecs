/* data "aws_ecs_cluster" "cluster" {
  cluster_name = local.cluster_name_full
}
 */
data "aws_vpc" "vpc" {
  id = var.vpc_id
}

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

data "aws_security_group" "proxy" {
  id = var.proxy_security_group
}


data "aws_lb" "service" {
  name = var.alb.name
}
