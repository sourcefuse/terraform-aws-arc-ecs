output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = module.ecs_cluster.ecs_cluster.name
}

output "ecs_cluster_configuration" {
  description = "The configuration details of the ECS cluster."
  value       = module.ecs_cluster.ecs_cluster.configuration
}

output "alb_name" {
  description = "The names of the ALBs."
  value       = [for alb in module.alb : alb.alb.name]
}


output "ecs_service_name" {
  description = "The service names of the ECS services."
  value       = [for service in module.ecs_service : service.ecs_service.service_name]
}


output "ecs_task_definition_arn" {
  description = "The ARNs of the ECS task definitions."
  value       = [for service in module.ecs_service : service.task.task_definition_arn]
}
