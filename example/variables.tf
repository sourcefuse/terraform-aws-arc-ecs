variable "aws_account" {
  type        = string
  description = "The AWS account to use"
}

variable "vpc_id" {
  type        = string
  description = "The VPC to use"
}

variable "environment" {
  type        = string
  description = "The environment to use"
}

variable "project" {
  type        = string
  description = "The project to use"
}

variable "service_name" {
  type        = string
  description = "The base name of the service (basically service name minus the environment)"
}

variable "cluster_name" {
  type        = string
  description = "The base name of the cluster"
}

variable "region" {
  type        = string
  description = "The region being deployed to"
  default     = "us-east-1"
}

variable "container_port" {
  type        = number
  description = "The port proxy-hydrator listen on in the container"
}

variable "container_health_check_path" {
  type        = string
  description = "The path that the ALB should use to conduct a health check"
}

variable "repository_name" {
  type        = string
  description = "The repository to use for the hydrator image"
}

variable "alb_port" {
  type        = number
  description = "The port the ALB will listen on"
}

variable "deregistration_delay" {
  type        = number
  description = "The amount of time to wait before changing the status of a target from draining to unused"
}

variable "tasks_desired_min" {
  type        = number
  description = "The minimum number of tasks desired"
}

variable "tasks_desired_max" {
  type        = number
  description = "The maximum number of tasks desired"
}

