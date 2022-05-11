output "output_name" {
  value = "output_value"
}
output "ecs_target_group_arn" {
  value = aws_lb_target_group.main.arn
}
output "aws_ecr_repository_url" {
  value = aws_ecr_repository.main.repository_url
}
output "alb" {
  value = aws_lb.main.dns_name
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}
output "ecs_security_group_id" {
  value = aws_security_group.ecs_tasks.id
}

output "ecs_cluster_id" {
  value = module.ecs_fargate.ecs_cluster_id
}
