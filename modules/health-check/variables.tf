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

variable "task_execution_role_arn" {
  type        = string
  description = "ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume."
}

variable "health_check_task_role_arn" {
  type        = string
  description = "ARN of IAM role that allows the health check container task to make calls to other AWS services."
  default     = null
}

variable "health_check_host_headers" {
  type        = list(string)
  description = <<-EOT
    A list of host header patterns to match. The maximum size of each pattern is 128 characters. Comparison is case insensitive.
    Wildcard characters supported: * (matches 0 or more characters) and ? (matches exactly 1 character).
    Only one pattern needs to match for the condition to be satisfied.
  EOT
  default     = ["*"]
}

variable "health_check_path_patterns" {
  type        = list(string)
  description = <<-EOT
    A list of path patterns to match against the request URL. Maximum size of each pattern is 128 characters.
    Comparison is case sensitive. Wildcard characters supported: * (matches 0 or more characters) and ? (matches exactly 1 character).
    Only one pattern needs to match for the condition to be satisfied. Path pattern is compared only to the path of the URL, not to
    its query string. To compare against the query string, use a query_string condition.
  EOT
  default = [
    "/"
  ]
}

################################################################################
## alb
################################################################################
// TODO - remove if not needed
#variable "lb_arn" {
#  type        = string
#  description = "ARN of the load balancer."
#}

variable "lb_security_group_ids" {
  type        = list(string)
  description = "LB Security Group IDs for ingress access to the health check task definition."
}

variable "lb_listener_arn" {
  type        = string
  description = "ARN of the load balancer listener."
}
