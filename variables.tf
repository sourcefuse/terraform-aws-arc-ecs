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
## logging
################################################################################
variable "log_group_retention_days" {
  type        = number
  description = <<-EOF
    Specifies the number of days you want to retain log events in the specified log group.
    Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096,
    1827, 2192, 2557, 2922, 3288, 3653, and 0.
    If you select 0, the events in the log group are always retained and never expire
  EOF
  default     = 90
}

variable "log_group_skip_destroy" {
  type        = bool
  description = "Set to true if you do not wish the log group (and any logs it may contain) to be deleted at destroy time, and instead just remove the log group from the Terraform state."
  default     = false
}

################################################################################
# service discovery namespaces
################################################################################
variable "service_discovery_private_dns_namespace" {
  type        = list(string)
  description = "The name of the namespace"
  default     = ["default"]
}

################################################################################
## task execution
################################################################################
variable "execution_policy_attachment_arns" {
  type        = list(string)
  description = "The ARNs of the policies you want to apply"
  default = [
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

################################################################################
## health check
################################################################################
variable "health_check_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for the health check tasks to run in. If not defined, this will use `var.alb_subnet_ids`."
  default     = []
}

################################################################################
## alb
################################################################################
variable "alb_acm_certificate_arn" {
  description = "ACM Certificate ARN for the ALB"
  type        = string
}

variable "alb_subnets_ids" {
  description = "Subnet Ids assigned to the LB"
  type        = list(string)
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

################################################################################
## cluster
################################################################################
variable "cluster_name_override" {
  description = "Name to assign the cluster. If null, the default will be `namespace-environment-ecs-fargate`"
  type        = string
  default     = null
}
