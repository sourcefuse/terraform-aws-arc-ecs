output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = module.ecs_cluster.ecs_cluster.name
}

output "alb_name" {
  description = "The names of the ALBs."
  value       = [for alb in module.alb : alb.alb.name]
}


output "ecs_service_name" {
  description = "The service names of the ECS services."
  value       = module.ecs_service[*].service_name
}

output "ecs_task_definition_arn" {
  description = "The ARNs of the ECS task definitions."
  value       = module.ecs_service[*].task_definition_arn
}
