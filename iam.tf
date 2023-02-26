################################################################################
## task role
################################################################################
data "aws_iam_policy_document" "task" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "task" {
  name               = "${local.cluster_name}-task"
  assume_role_policy = data.aws_iam_policy_document.task.json

  tags = merge(var.tags, tomap({
    Name = "${local.cluster_name}-task"
  }))
}

resource "aws_iam_role_policy" "task" {
  count = var.attach_task_role_policy ? 1 : 0

  name   = "${local.cluster_name}-task"
  role   = aws_iam_role.task.id
  policy = var.task_role_policy
}

################################################################################
## task execution role
################################################################################
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name_prefix        = "${local.cluster_name}-execution-"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = merge(var.tags, tomap({
    NamePrefix = "${local.cluster_name}-execution-"
  }))
}

resource "aws_iam_policy_attachment" "execution" {
  for_each = toset(var.execution_policy_attachment_arns)

  name       = "${local.cluster_name}-execution"
  policy_arn = each.value
  roles      = [aws_iam_role.execution.name]
}

################################################################################
## secrets manager
################################################################################
resource "aws_iam_policy" "secrets_manager_read_policy" {
  name = "${local.cluster_name}-secrets-manager-ro"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Resource = "*"
        Action = [
          "secretsmanager:GetSecretValue"
        ],
      }
    ]
  })

  tags = merge(var.tags, tomap({
    Name = "${local.cluster_name}-secrets-manager-ro"
  }))
}

resource "aws_iam_policy_attachment" "secrets_manager_read" {
  name       = "${local.cluster_name}-secrets-manager-ro"
  roles      = [aws_iam_role.execution.name]
  policy_arn = aws_iam_policy.secrets_manager_read_policy.arn
}
