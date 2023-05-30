################################################################################
## shared
################################################################################
variable "vpc_id" {
  description = "Id of the VPC where the resources will live"
  type        = string
}

variable "tags" {
  description = "Tags to assign the resources."
  type        = map(string)
  default     = {}
}

################################################################################
## ecs
################################################################################
variable "cluster_name" {
  description = "Name of the ECS cluster."
  type        = string
}

variable "cluster_id" {
  description = "ID of the ECS cluster."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs to run health check task in"
  type        = list(string)
}


################################################################################
## task definitions
################################################################################
variable "task_definition_cpu" {
  type        = number
  description = "Number of cpu units used by the task. If the requires_compatibilities is FARGATE this field is required."
  default     = 1024
}

variable "task_definition_memory" {
  type        = number
  description = "Amount (in MiB) of memory used by the task. If the requires_compatibilities is FARGATE this field is required."
  default     = 2048
}

variable "task_execution_role_arn" {
  type        = string
  description = "ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume."
}

variable "health_check_path_pattern" {
  type        = string
  description = "Path pattern to match against the request URL."
  default     = "/"
}

variable "health_check_route_53_records" {
  type        = list(string)
  description = "List of A record domains to create for the health check service"
}

variable "health_check_route_53_record_type" {
  default     = "A"
  type        = string
  description = "Health check Route53 record type"
}

variable "health_check_image" {
  default     = "ealen/echo-server"
  type        = string
  description = "Docker image used for the health-check"
}

variable "health_check_launch_type" {
  default     = "FARGATE"
  type        = string
  description = "Launch type for the health check service."
}

variable "health_check_desired_count" {
  default     = 1
  type        = number
  description = "Number of ECS tasks to run for the health check."
}

variable "alb_dns_name" {
  type        = string
  description = "ALB DNS name to create A record for health check service"
}

variable "alb_zone_id" {
  type        = string
  description = "ALB Route53 zone ID to create A record for health check service"
}

variable "route_53_zone_id" {
  type        = string
  description = "Route53 zone ID used for looking up and creating an `A` record for the health check service"
}

################################################################################
## alb
################################################################################
variable "lb_security_group_ids" {
  type        = list(string)
  description = "LB Security Group IDs for ingress access to the health check task definition."
}

variable "lb_listener_arn" {
  type        = string
  description = "ARN of the load balancer listener."
}

################################################################################
## route 53
################################################################################
variable "externally_managed_route_53_record" {
  type        = bool
  description = "If there is a Route 53 Zone externally managed from the account you are running in. If `true`, you will have to manage your DNS yourself."
  default     = false
}
