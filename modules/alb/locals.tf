# Collect public subnets in a list
locals {
  public_subnets = [
    for s in data.aws_subnet.public :
    s.id if lookup(s.tags, "Type", "") == "public"
  ]
}
