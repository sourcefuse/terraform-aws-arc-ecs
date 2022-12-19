################################################################################
## lookups
################################################################################
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = var.vpc_names
  }
}

## public
data "aws_subnets" "public" {
  filter {
    name = "tag:Name"

    values = var.public_subnet_names
  }
}

## security group
data "aws_security_groups" "web_sg" {
  filter {
    name   = "group-name"
    values = var.web_security_group_names
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

## cluster ami
data "aws_ami" "this" {
  owners      = var.ami_owners
  most_recent = "true"

  dynamic "filter" {
    for_each = var.ami_filter

    content {
      name   = filter.key
      values = filter.value
    }
  }
}
