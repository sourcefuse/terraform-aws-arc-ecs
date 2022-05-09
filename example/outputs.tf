output "output_name" {
  value = "output_value"
}
output "ecs_target_group_arn" {
  value = aws_lb_target_group.main.arn
}
