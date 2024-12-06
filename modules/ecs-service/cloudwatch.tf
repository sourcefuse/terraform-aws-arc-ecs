resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${local.service_name_full}"
  retention_in_days = 7  
}
