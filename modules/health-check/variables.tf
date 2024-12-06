# General variables
variable "vpc_id" {
  type        = string
  description = "The VPC the service will be deployed in"
}

variable "environment" {
  type        = string
  description = "The environment associated with the service"
}

# ECS-specific variables
variable "ecs" {
  type = object({
    cluster_name            = string
    service_name            = string
    repository_name         = string
    enable_load_balancer    = bool
    aws_lb_target_group_arn = optional(string)
  })
  description = "The ECS-specific values to use such as cluster, service, and repository names."
}

# Task-specific variables
variable "task" {
  type = object({
    tasks_desired               = optional(number) // Default will be set below in locals
    container_vcpu              = optional(number) // Default will be set below in locals
    container_memory            = optional(number) // Default will be set below in locals
    container_port              = number            // Required, no default needed
    container_health_check_path = optional(string)  // Default will be set below in locals
    container_definition        = optional(string)   // Default will be set below in locals
    environment_variables       = optional(map(string)) // Default will be set below in locals
    task_execution_role         = optional(string)   // Default will be set below in locals
  })

  description = "Task-related information (vCPU, memory, # of tasks, port, and health check info.)"

  default = {
    tasks_desired               = 1                        // Default number of tasks
    container_vcpu              = 512                        // Default vCPU allocation
    container_memory            = 1024                       // Default memory allocation
    container_port              = 80                         // Example default port (you can change this)
    container_health_check_path = "/health"                 // Example health check path (you can change this)
    environment_variables       = {}                         // Default to an empty map
  }
}

# Load balancer
variable "alb" {
  type = object({
    name                 = string
    listener_port        = number
    deregistration_delay = optional(number)
    security_group_id    = string
  })
  description = "ALB-related information (listening port, deletion protection, security group)"
  default = {
    name                 = ""                     // Default ALB name
    listener_port        = 80                                  // Default listener port
    deregistration_delay = 300                                 // Default deregistration delay
    security_group_id    = ""             // Example default security group ID
  }
}

