################################################################################
## defaults
################################################################################
variable "name" {
  description = "Name to assign the resource"
  type        = string
  default     = ""
}

variable "namespace" {
  description = "Namespace the resource belongs to"
  type        = string
}

variable "environment" {
  description = "Name of the environment the resource belongs to"
  type        = string
}

variable "vpc_id" {
  description = "Id of the VPC where the resources will live"
  type        = string
}

variable "tags" {
  description = "Tags to assign the resources"
  type        = map(string)
  default     = {}
}

################################################################################
## alb
################################################################################
variable "alb_target_groups" {
  description = "Target group configuration for downstream application communication."
  type = list(object({
    name         = string
    port         = number
    protocol     = string
    target_type  = optional(string)
    host_headers = optional(list(string))
    path_pattern = optional(list(string))
  }))
  default = []
}

variable "cross_zone_load_balancing_enabled" {
  description = "A boolean flag to enable/disable cross zone load balancing"
  type        = bool
  default     = true
}

variable "deletion_protection_enabled" {
  type        = bool
  description = "A boolean flag to enable/disable deletion protection for ALB"
  default     = false
}

variable "deregistration_delay" {
  description = "The amount of time to wait in seconds before changing the state of a deregistering target to unused"
  type        = number
  default     = 15
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  type        = number
  default     = 60
}

variable "internal" {
  description = "Internal or external facing ALB."
  type        = bool
  default     = false
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the subnets for your load balancer. The possible values are `ipv4` and `dualstack`."
  type        = string
  default     = "ipv4"
}

variable "security_group_ids" {
  description = "Security group Ids for access"
  type        = list(string)
}

variable "subnet_ids" {
  description = "Subnet Ids assigned to the LB"
  type        = list(string)
}

variable "http_ingress_cidr_blocks" {
  description = "List of CIDR blocks to allow in HTTP security group"
  type        = list(string)
  default = [
    "0.0.0.0/0"
  ]
}

variable "https_ingress_cidr_blocks" {
  description = "List of CIDR blocks to allow in HTTPS security group"
  type        = list(string)
  default = [
    "0.0.0.0/0"
  ]
}

variable "acm_certificate_arn" {
  description = "ACM Certificate ARN for the ALB"
  type        = string
}

variable "lb_ssl_policy" {
  description = "SSL policy for the ALB."
  type        = string
  default     = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
}

################################################################################
## logs
################################################################################
variable "access_logs_enabled" {
  description = "A boolean flag to enable/disable access_logs"
  type        = bool
  default     = true
}

variable "alb_access_logs_s3_bucket_force_destroy" {
  type        = bool
  default     = false
  description = "A boolean that indicates all objects should be deleted from the ALB access logs S3 bucket so that the bucket can be destroyed without error"
}

variable "alb_access_logs_s3_bucket_force_destroy_enabled" {
  type        = bool
  default     = false
  description = <<-EOT
    When `true`, permits `force_destroy` to be set to `true`.
    This is an extra safety precaution to reduce the chance that Terraform will destroy and recreate
    your S3 bucket, causing COMPLETE LOSS OF ALL DATA even if it was stored in Glacier.
    WARNING: Upgrading this module from a version prior to 0.27.0 to this version
      will cause Terraform to delete your existing S3 bucket CAUSING COMPLETE DATA LOSS
      unless you follow the upgrade instructions on the Wiki [here](https://github.com/cloudposse/terraform-aws-s3-log-storage/wiki/Upgrading-to-v0.27.0-(POTENTIAL-DATA-LOSS)).
      See additional instructions for upgrading from v0.27.0 to v0.28.0 [here](https://github.com/cloudposse/terraform-aws-s3-log-storage/wiki/Upgrading-to-v0.28.0-and-AWS-provider-v4-(POTENTIAL-DATA-LOSS)).
    EOT
}
