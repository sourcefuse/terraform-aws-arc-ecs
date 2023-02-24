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
variable "task_definition_requires_compatibilities" {
  type        = list(string)
  description = "Set of launch types required by the task. The valid values are EC2 and FARGATE."
  default     = ["FARGATE"]
}

variable "task_definition_network_mode" {
  type        = string
  description = "Docker networking mode to use for the containers in the task. Valid values are none, bridge, awsvpc, and host."
  default     = "awsvpc"
}

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

################################################################################
## alb
################################################################################
variable "lb_arn" {
  type        = string
  description = "ARN of the load balancer."
}

variable "lb_ssl_policy" {
  type        = string
  description = "Load Balancer SSL policy."
  default     = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
}

variable "lb_acm_certificate_arn" {
  type        = string
  description = "Load Balancer ACM Certificate ARN."
}

variable "lb_security_group_ids" {
  type        = list(string)
  description = "LB Security Group IDs for ingress access to the health check task definition."
}
