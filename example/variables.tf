variable "name" {
  default = "default_value"
}

variable "environment" {
  default = ""
}

variable "region" {
  default = "us-east-1"
}

variable "alb_tls_cert_arn" {
  description = "The ARN of the certificate that the ALB uses for https"
}

variable "subnets" {
  description = "List of subnet IDs"
  default     = []
}

variable "health_check_path" {
  description = "Path to check if the service is healthy, e.g. \"/status\""
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "service_desired_count" {
  description = "Number of services running in parallel"
}

variable "container_image" {
  description = "Docker image to be launched"
}

variable "container_cpu" {
  description = "Cpu units for container"
}


variable "container_memory" {
  description = "Memory for container"
}

variable "container_port" {
  description = "Memory for container"
}
