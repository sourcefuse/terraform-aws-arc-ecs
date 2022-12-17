################################################################################
## shared
################################################################################
variable "region" {
  description = "AWS region"
  type        = string
}

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

################################################################################
## kms
################################################################################
variable "kms_admin_iam_role_identifier_arns" {
  description = "IAM Role ARN to add to the KMS key for management"
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

variable "autoscaling_capacity_providers" {
  description = "Map of autoscaling capacity provider definitions to create for the cluster"
  type        = any
  default     = {}
}

################################################################################
## fargate
################################################################################
variable "fargate_capacity_providers" {
  description = "Map of Fargate capacity provider definitions to use for the cluster"
  type        = any
  default     = {}
}

################################################################################
## cloudwatch
################################################################################
variable "cloudwatch_kms_key_name_override" {
  description = "Cloudwatch. If null, the default will be `/aws/ecs/namespace-environment-ecs-fargate`"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_name_override" {
  description = "Log group name override. If null, the default will be `/aws/ecs/namespace-environment-ecs-fargate`"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_retention_days" {
  description = "Days to retain logs in the log group"
  type        = number
  default     = 7
}
