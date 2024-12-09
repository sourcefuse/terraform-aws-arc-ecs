# Fetch all subnets in the VPC
data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# Filter subnets with the "Type=public" tag
data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.all.ids)

  id = each.value
}

# To get VPC CIDR for ALB security group as default ingress
data "aws_vpc" "this" {
  id = var.vpc_id
}
