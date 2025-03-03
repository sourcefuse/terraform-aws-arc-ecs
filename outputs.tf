output "ecs_cluster" {
  value = {
    name = aws_ecs_cluster.this.name
    id   = aws_ecs_cluster.this.id
  }
}
