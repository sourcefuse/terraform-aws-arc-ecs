// TODO - add descriptions
output "forward_listener_rule_arn" {
  value = aws_lb_listener_rule.forward.arn
}

output "forward_listener_rule_id" {
  value = aws_lb_listener_rule.forward.id
}

output "target_group_arn" {
  value = aws_lb_target_group.health_check.arn
}

output "target_group_id" {
  value = aws_lb_target_group.health_check.id
}

output "security_group_arn" {
  value = aws_security_group.health_check.id
}

output "security_group_id" {
  value = aws_security_group.health_check.id
}
