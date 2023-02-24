################################################################################
## lookups
################################################################################
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = var.vpc_name != null ? [var.vpc_name] : ["${var.namespace}-${var.environment}-vpc"]
  }
}

## public
data "aws_subnets" "public" {
  filter {
    name = "tag:Name"

    values = length(var.public_subnet_names) > 0 ? var.public_subnet_names : [
      "${var.namespace}-${var.environment}-public-${var.region}a",
      "${var.namespace}-${var.environment}-public-${var.region}b"
    ]
  }
}

## private
data "aws_subnets" "private" {
  filter {
    name = "tag:Name"

    values = length(var.private_subnet_names) > 0 ? var.private_subnet_names : [
      "${var.namespace}-${var.environment}-private-${var.region}a",
      "${var.namespace}-${var.environment}-private-${var.region}b"
    ]
  }
}
