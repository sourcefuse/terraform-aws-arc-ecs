module "ecs_fargate" {
  source = "../."
  subnets = var.subnets
}
