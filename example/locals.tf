locals {
  cluster_name_full   = "${var.ecs.cluster_name}-${var.environment}"
  service_name_full   = "${var.ecs.service_name}-${var.environment}"
}
