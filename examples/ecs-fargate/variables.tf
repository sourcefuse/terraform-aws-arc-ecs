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
