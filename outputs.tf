output "aws_ecr_repository_url" {
  value = aws_ecr_repository.main.repository_url
}

output "alb" {
  value = aws_lb.main.dns_name
}
