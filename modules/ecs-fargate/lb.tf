resource "aws_lb_target_group" "tg" {
  name                 = "${local.service_name_full}-tg"
  port                 = local.task.container_port
  protocol             = "HTTP"
  vpc_id               = data.aws_vpc.vpc.id
  target_type          = "ip"
  deregistration_delay = local.alb.deregistration_delay

  dynamic "health_check" {
    for_each = local.task.container_health_check_path != null ? [0] : []
    content {
      enabled  = true
      interval = 30
      port     = local.task.container_port
      path     = local.task.container_health_check_path
    }
  }
  tags = {
        Name = "${local.service_name_full}-tg",
        Environment = "${var.environment}",
        Project = "${var.project}",
        Service = "${var.ecs.service_name_tag}"
    }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = data.aws_lb.service.arn
  port              = local.alb.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
  tags = {
        Environment = "${var.environment}",
        Project = "${var.project}",
        Service = "${var.ecs.service_name_tag}"
    }
}
