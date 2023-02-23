################################################################################
## lookups
################################################################################
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

## public
data "aws_subnets" "public" {
  filter {
    name = "tag:Name"

    values = var.public_subnet_names
  }
}

## public
data "aws_subnets" "private" {
  filter {
    name = "tag:Name"

    values = var.private_subnet_names
  }
}
