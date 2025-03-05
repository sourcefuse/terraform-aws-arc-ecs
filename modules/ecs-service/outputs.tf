output "service_name" {
  description = "The name of the ECS service."
  value       = aws_ecs_service.this[*].name
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS task definition"
  value       = aws_ecs_task_definition.this[*].arn
}

output "ecs_task_role_arn" {
  description = "The ARN of the IAM role assigned to the ECS task"
  value       = aws_iam_role.task_role[*].arn
}

output "ecs_service_arn" {
  description = "The ARN of the ECS service"
  value       = aws_ecs_service.this[*].id
}
