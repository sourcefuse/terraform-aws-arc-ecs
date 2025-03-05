output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = length(module.ecs_service) > 0 ? module.ecs_service[0].ecs_service : null
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = module.ecs_service[0].service_name
}

output "ecs_service_arn" {
  description = "The ARN of the ECS service"
  value       = module.ecs_service[0].ecs_service_arn
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS task definition"
  value       = module.ecs_service[0].ecs_task_definition_arn
}
