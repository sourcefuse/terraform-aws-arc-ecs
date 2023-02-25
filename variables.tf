################################################################################
## shared
################################################################################
variable "environment" {
  description = "ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'"
  type        = string
}

variable "namespace" {
  type        = string
  description = "Namespace for the resources."
}

variable "tags" {
  description = "Tags to assign the resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "Id of the VPC where the resources will live"
  type        = string
}
################################################################################
## alb
################################################################################
variable "alb_acm_certificate_arn" {
  description = "ACM Certificate ARN for the ALB"
  type        = string
}

variable "alb_ssl_policy" {
  description = "SSL policy for the ALB."
  type        = string
  default     = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
}

variable "alb_internal" {
  description = "Determines if this load balancer is internally or externally facing."
  type        = bool
  default     = false
}

variable "alb_idle_timeout" {
  description = "The time that the connection is allowed to be idle."
  type        = number
  default     = 300
}

variable "alb_subnets_ids" {
  description = "Subnet Ids assigned to the LB"
  type        = list(string)
}

variable "task_subnet_ids" {
  description = "Subnet Ids to run tasks in"
  type        = list(string)
}

################################################################################
## cluster
################################################################################
variable "cluster_name_override" {
  description = "Name to assign the cluster. If null, the default will be `namespace-environment-ecs-fargate`"
  type        = string
  default     = null
}
