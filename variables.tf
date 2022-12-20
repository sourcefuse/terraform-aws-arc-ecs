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

variable "vpc_id" {
  description = "Id of the VPC where the resources will live"
  type        = string
}

variable "health_check_route53_zone" {
  type        = string
  description = "Route 53 zone for health check"
}

################################################################################
## alb
################################################################################
variable "alb_acm_certificate_arn" {
  description = "ARN to the certificate that will be used on the ALB."
  type        = string
}

#variable "alb_target_groups" {
#  description = "Target groups to add to the ALB"
#  type = list(object({
#    name         = string
#    port         = number
#    protocol     = string
#    target_type  = string
#    host_headers = list(string)
#    path_pattern = list(string)
#  }))
#  default = [
#    {
#      name         = "example"
#      port         = 443
#      protocol     = "HTTPS"
#      target_type  = "ip"
#      host_headers = ["example.arc-demo.io"]
#      path_pattern = [
#        "/",
#        "/*"
#      ]
#    }
#  ]
#}

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

variable "alb_security_group_ids" {
  description = "Security group Ids for access"
  type        = list(string)
}

variable "task_subnet_ids" {
  description = "Subnet Ids to run tasks in"
  type        = list(string)
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

################################################################################
## fargate
################################################################################
variable "fargate_capacity_providers" {
  description = "Map of Fargate capacity provider definitions to use for the cluster"
  type        = any
  default = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }
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
