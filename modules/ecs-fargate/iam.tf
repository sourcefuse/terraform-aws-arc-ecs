# The ECS Task role permissions
resource "aws_iam_role" "task_role" {
  name               = "${local.service_name_full}-task-role"
  assume_role_policy = data.aws_iam_policy_document.document.json
  tags = {
        Name         = "${local.service_name_full}-task-role",
        Environment  = "${var.environment}",
        Project      = "${var.project}",
        Service      = "${var.ecs.service_name_tag}"
    }
}

# The ECS Task Execution role IAM permissions
resource "aws_iam_role" "execution_role" {
  name               = "${local.service_name_full}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.document.json
  tags = {
        Name         = "${local.service_name_full}-execution-role",
        Environment  = "${var.environment}",
        Project      = "${var.project}",
        Service      = "${var.ecs.service_name_tag}"
    }
}

resource "aws_iam_role_policy" "execution_role" {
  name = "${local.service_name_full}-execution-role"
  role = aws_iam_role.execution_role.id

  policy = file(local.task.task_execution_role)
}

# Policy document (used by both)
data "aws_iam_policy_document" "document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}
