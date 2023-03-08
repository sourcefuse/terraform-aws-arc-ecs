output "cluster_name" {
  description = "Name of the ECS Cluster"
  value       = module.ecs.cluster_name
}

## health check
output "health_check_fqdn" {
  description = "Health check FQDN record created in Route 53."
  value       = module.ecs.health_check_fqdn
}
