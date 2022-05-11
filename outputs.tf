output "aws_ecr_repository_url" {
  value = aws_ecr_repository.main.repository_url
}

output "alb" {
  value = aws_lb.main.dns_name
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "ecs_target_group_arn" {
  value = aws_lb_target_group.main.arn
}
