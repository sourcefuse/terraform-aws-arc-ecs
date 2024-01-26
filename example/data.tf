################################################################################
## lookups
################################################################################
data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    ## if `var.vpc_name` is unassigned, it will attempt to lookup the
    ## vpc name created by github.com/sourcefuse/terraform-aws-ref-arch-network
    values = var.vpc_name != null ? [var.vpc_name] : ["${var.namespace}-${var.environment}-vpc"]
  }
}

data "aws_route53_zone" "this" {
  name = var.route_53_zone
}

## public
data "aws_subnets" "public" {
  filter {
    name = "tag:Name"

    ## if `var.public_subnet_names` is unassigned, it will attempt to lookup the
    ## subnets created by github.com/sourcefuse/terraform-aws-ref-arch-network
    values = length(var.public_subnet_names) > 0 ? var.public_subnet_names : [
      "${var.namespace}-${var.environment}-public-subnet-public-${var.region}a",
      "${var.namespace}-${var.environment}-public-subnet-public-${var.region}b"
    ]
  }
}

## private
data "aws_subnets" "private" {
  filter {
    name = "tag:Name"

    ## if `var.private_subnet_names` is unassigned, it will attempt to lookup the
    ## subnets created by github.com/sourcefuse/terraform-aws-ref-arch-network
    values = length(var.private_subnet_names) > 0 ? var.private_subnet_names : [
      "${var.namespace}-${var.environment}-private-subnet-private-${var.region}a",
      "${var.namespace}-${var.environment}-private-subnet-private-${var.region}b"
    ]
  }
}
