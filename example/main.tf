output "ecs_cluster_id" {
  value = aws_ecs_cluster.main.id
}

module "ecs_fargate" {
  source           = "../."
  vpc_id           = var.vpc_id
  environment      = var.environment
  name             = var.name
  subnets          = var.subnets
  region           = var.region
  alb_tls_cert_arn = var.alb_tls_cert_arn
}

module "ecs_service_fargate" {
  source                = "../health_check_service"
  environment           = var.environment
  cluster               = module.ecs_fargate.ecs_cluster_id
  name                  = var.name
  health_check_path     = var.health_check_path
  subnets               = var.subnets
  service_desired_count = var.service_desired_count
  container_port        = var.container_port
  region                = var.region
  container_image       = var.container_image
  container_cpu         = var.container_cpu
  container_memory      = var.container_memory
  vpc_id                = var.vpc_id
  container_environment = var.container_environment

  depends_on = [
    module.ecs_fargate
  ]

}
