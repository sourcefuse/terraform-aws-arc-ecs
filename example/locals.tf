locals {
  cluster_name_full   = "${var.cluster_name}-${var.environment}"
  service_name_full   = "${var.service_name}-${var.environment}"
  sqs_queue_name_full = "${var.sqs_queue_name}-${var.environment}"
}
