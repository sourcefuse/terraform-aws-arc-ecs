resource "aws_security_group" "alb" {
  name        = "${local.service_name_full}-alb"
  description = "Allow HTTP traffic to the application proxy"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description     = "Allow HTTP Traffic"
    from_port       = local.alb.listener_port
    to_port         = local.alb.listener_port
    protocol        = "tcp"
    cidr_blocks     = [for s in data.aws_subnet.private : s.cidr_block]
    security_groups = [data.aws_security_group.proxy.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
     Name        = "${local.service_name_full}-alb",
     Environment = var.environment,
     Project     = "${var.project}",
     Service     = "${var.ecs.service_name_tag}",
     Description = "Allow HTTP traffic to the application proxy"
     owner       = "devops"
  }
}

resource "aws_security_group" "ecs" {
  name        = "${local.service_name_full}-ecs"
  description = "Allow traffic from the ALB into the Docker containers."
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description     = "Allow inbound proxy traffic"
    from_port       = local.task.container_port
    to_port         = local.task.container_port
    protocol        = "tcp"
    cidr_blocks     = [for s in data.aws_subnet.private : s.cidr_block]
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
     Name        = "${local.service_name_full}-ecs",
     Environment = var.environment,
     Project     = "${var.project}",
     Service     = "${var.ecs.service_name_tag}",
     Description = "Allow traffic from the ALB into the Docker containers."
     owner       = "devops"
  }
}
