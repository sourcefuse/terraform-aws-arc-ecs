variable "region" {
  type        = string
  description = "AWS region"
}

variable "environment" {
  type        = string
  description = "The environment associated with the ECS service"
}

variable "namespace" {
  type        = string
  description = "Namespace of the project, i.e. arc"
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC to add the resources"
  default     = "arc-poc-vpc"
}

variable "subnet_names" {
  type        = list(string)
  description = "List of subnet names to lookup"
  default     = ["arc-poc-private-subnet-private-us-east-1a", "arc-poc-private-subnet-private-us-east-1b"]
}
