output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.ecs_cluster[0].ecs_cluster
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
