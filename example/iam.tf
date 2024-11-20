resource "aws_iam_role_policy" "policies" {
  for_each = fileset("${path.module}/container/task_role", "*.json")

  name = "${local.service_name_full}-task-role-${element(split(".", each.value), 0)}"
  role = module.aws_service.task_role_id

  policy = templatefile("${path.module}/container/task_role/${each.value}", {
    aws_region       = var.region
    aws_account      = var.aws_account
    environment      = var.environment
  })

  depends_on = [
    module.ecs-fargate
  ]
}
