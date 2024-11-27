output "cluster_name" {
  description = "Name of the ECS Cluster"
  value       = module.ecs.cluster_name
}
output "cluster_arn" {
  description = "ECS Cluster ARN"
  value       = module.ecs.cluster_arn
}
output "cluster_id" {
  description = "ECS Cluster ID"
  value       = module.ecs.cluster_id
}
