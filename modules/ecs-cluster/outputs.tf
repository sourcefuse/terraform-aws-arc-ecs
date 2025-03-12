output "ecs_cluster" {
  value = {
    name = aws_ecs_cluster.this.name
    id   = aws_ecs_cluster.this.id
  }
}

output "launch_template_id" {
  description = "The ID of the EC2 launch template"
  value       = var.capacity_provider.use_fargate ? null : aws_launch_template.this[0].id
}
