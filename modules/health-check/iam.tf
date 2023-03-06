################################################################################
## iam
################################################################################
data "aws_iam_policy_document" "assume" {
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
  name_prefix        = "${var.cluster_name}-health-check-task-"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = merge(var.tags, tomap({
    NamePrefix = "${var.cluster_name}-health-check-task-"
  }))
}

resource "aws_iam_role_policy_attachment" "aws_ec2_container_service_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  role       = aws_iam_role.task.name
}
