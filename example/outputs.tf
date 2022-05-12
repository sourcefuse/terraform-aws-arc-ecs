output "output_name" {
  value = "output_value"
}

output "ecs_cluster_id" {
  value = module.ecs_fargate.ecs_cluster_id
}

output "alb" {
  value = module.ecs_fargate.alb
}
