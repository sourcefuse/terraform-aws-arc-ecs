# General variables
variable "vpc_id" {
  type        = string
  description = "The VPC the service will be deployed in"
}

variable "aws_region" {
  type        = string
  description = "The AWS region to use"
}

variable "environment" {
  type        = string
  description = "The environment associated with the service"
}

variable "project" {
  type        = string
  description = "The project associated with the service"
}

variable "proxy_security_group" {
  type        = string
  description = "The associated SG of the Dopple Proxy"
  default     = none
}

# ECS-specific variables
variable "ecs" {
  type = object({
    cluster_name       = string
    service_name       = string
    service_name_short = string
    service_name_tag   = string
    repository_name    = string
  })
  description = "The ECS-specific values to use such as cluster, service, and repository names."
}

# Task-specific variables
variable "task" {
  type = object({
    tasks_desired               = optional(number)
    container_vcpu              = optional(number)
    container_memory            = optional(number)
    container_port              = number
    container_health_check_path = optional(string)
    container_definition        = optional(string)
    environment_variables       = optional(map(string))
    task_execution_role         = optional(string)
  })
  description = "Task-related information (vCPU, memory, # of tasks, port, and health check info.)"
}

# Load balancer
variable "alb" {
  type = object({
    name                 = string
    listener_port        = number
    deregistration_delay = optional(number)
  })
  description = "ALB-related information (listening port, internal, and deletion protection.)"
}

# Autoscaling parameters
variable "autoscaling" {
  type = object({
    namespace = optional(string)
    scale_up = object({
      evaluation_periods  = optional(string)
      period              = optional(string)
      threshold           = string
      comparison_operator = optional(string)
      statistic           = optional(string)
      cooldown            = string
      step_adjustment     = list(map(number))
    })
    scale_down = object({
      evaluation_periods  = optional(string)
      period              = optional(string)
      threshold           = string
      comparison_operator = optional(string)
      statistic           = optional(string)
      cooldown            = string
      step_adjustment     = list(map(number))
    })
    dimensions       = map(string)
    metric_name      = optional(string)
    minimum_capacity = number
    maximum_capacity = number
  })
}