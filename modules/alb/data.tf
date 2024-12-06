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