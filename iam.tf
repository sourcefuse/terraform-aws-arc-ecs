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
  name               = "${local.cluster_name}-execution"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = merge(var.tags, tomap({
    Name = "${local.cluster_name}-execution"
  }))
}

resource "aws_iam_role_policy_attachment" "execution" {
  for_each = toset(var.execution_policy_attachment_arns)

  policy_arn = each.value
  role       = aws_iam_role.execution.name
}
