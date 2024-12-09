variable "environment" {
  type        = string
  description = "The environment associated with the service"
}

variable "vpc_id" {
  type        = string
  description = "VPC in which security group for ALB has to be created"
}

variable "ecs_service" {
  type = object({
    cluster_name             = string
    service_name             = string
    repository_name          = string
    enable_load_balancer     = bool
    aws_lb_target_group_name = optional(string)
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
variable "lb" {
  type = object({
    name                 = string
    listener_port        = number
    deregistration_delay = optional(number)
    security_group_id    = string
  })
  description = "ALB-related information (listening port, deletion protection, security group)"
}
