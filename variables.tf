variable "profile" {
  description = "The aws profile to use"
}

variable "region" {
  description = "The aws region"
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "alb_security_groups" {
  description = "Comma separated list of security groups"
}

variable "alb_tls_cert_arn" {
  description = "The ARN of the certificate that the ALB uses for https"
}

variable "health_check_path" {
  description = "Path to check if the service is healthy, e.g. \"/status\""
}

variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "subnets" {
  description = "List of subnet IDs"
}
/*
variable "ecs_service_security_groups" {
  description = "Comma separated list of security groups"
}
*/
variable "container_port" {
  description = "Port of container"
}

variable "container_cpu" {
  description = "The number of cpu units used by the task"
}

variable "container_memory" {
  description = "The amount (in MiB) of memory used by the task"
}

variable "container_image" {
  description = "Docker image to be launched"
}

#variable "aws_alb_target_group_arn" {
#  description = "ARN of the alb target group"
#}

variable "service_desired_count" {
  description = "Number of services running in parallel"
}
/*
variable "container_environment" {
  description = "The container environmnent variables"
  type        = list
}

variable "container_secrets" {
  description = "The container secret environmnent variables"
  type        = list
}

variable "container_secrets_arns" {
  description = "ARN for secrets"
}

variable "application-secrets" {
  description = "A map of secrets that is passed into the application. Formatted like ENV_VAR = VALUE"
  type        = map
}
*/
