/*
output "ecs_target_group_arn" {
  value = module.ecs_fargate.aws_lb_target_group.main.arn
}
output "aws_ecr_repository_url" {
  value = module.ecs_fargate.aws_ecr_repository.main.repository_url
}
output "alb" {
  value = module.ecs_fargate.aws_lb.main.dns_name
}

output "ecs_execution_role_arn" {
  value = module.ecs_fargate.aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  value = module.ecs_fargate.aws_iam_role.ecs_task_role.arn
}
*/
output "ecs_cluster_id" {
  value = module.ecs_fargate.ecs_cluster_id
}

output "ecs_task_def_arn" {
  value = module.ecs_fargate.aws_ecs_task_definition.main.arn
}

output "ecs_security_group_id" {
  value = module.ecs_fargate.aws_security_group.ecs_tasks.id
}
