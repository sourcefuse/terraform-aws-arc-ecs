output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.ecs_cluster.ecs_cluster_name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = module.ecs_services.service_name
}

output "ecs_service_arn" {
  description = "The ARN of the ECS service"
  value       = module.ecs_services.ecs_service_arn
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS task definition"
  value       = module.ecs_services.ecs_task_definition_arn
}
