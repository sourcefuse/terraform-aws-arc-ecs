################################################################################
## shared
################################################################################
variable "environment" {
  description = "ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'"
  type        = string
}

variable "namespace" {
  type        = string
  description = <<-EOF
    Namespace your resource belongs to.
    Usually an abbreviation of your organization name, e.g. 'example' or 'arc', to help ensure generated IDs are globally unique"
  EOF
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
  default     = 30
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
  default     = ["default.example.local"]
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

variable "route_53_zone" {
  type        = string
  description = "Route 53 domain to generate an ACM request for and to create A records against, i.e. sfrefarch.com. A wildcard subject alternative name is generated with the certificate."
}

variable "health_check_route_53_records" {
  type        = list(string)
  description = "List of Route 53 records for the health check service."
}
################################################################################
## acm
################################################################################
variable "create_acm_certificate" {
  description = "Create an ACM Certificate to use with the ALB"
  type        = bool
  default     = true
}

variable "acm_domain_name" {
  description = "Domain name the ACM Certificate belongs to"
  type        = string
}

variable "acm_subject_alternative_names" {
  description = "Subject alternative names for the ACM Certificate"
  type        = list(string)
  default     = []
}

variable "acm_process_domain_validation_options" {
  description = "Flag to enable/disable processing of the record to add to the DNS zone to complete certificate validation"
  type        = bool
  default     = true
}

variable "acm_process_domain_validation_record_ttl" {
  description = "The TTL of the record to add to the DNS zone to complete certificate validation"
  type        = string
  default     = "300"
}

################################################################################
## alb
################################################################################
variable "alb_certificate_arn" {
  type        = string
  description = "ALB Certificate ARN. If `var.create_acm_certificate` is `true`, this will be ignored."
  default     = null
}

variable "alb_subnet_ids" {
  type        = list(string)
  description = "Subnet Ids assigned to the LB"
}

variable "alb_internal" {
  type        = bool
  description = "Determines if this load balancer is internally or externally facing."
  default     = false
}

variable "alb_idle_timeout" {
  type        = number
  description = "The time that the connection is allowed to be idle."
  default     = 300
}

variable "alb_ssl_policy" {
  type        = string
  description = "Load Balancer SSL policy."
  default     = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
}

variable "access_logs_enabled" {
  type        = bool
  description = "A boolean flag to enable/disable access_logs"
  default     = true
}

variable "alb_access_logs_s3_bucket_force_destroy" {
  type        = bool
  default     = false
  description = "A boolean that indicates all objects should be deleted from the ALB access logs S3 bucket so that the bucket can be destroyed without error"
}

variable "alb_access_logs_s3_bucket_force_destroy_enabled" {
  type        = bool
  description = <<-EOT
    When `true`, permits `force_destroy` to be set to `true`.
    This is an extra safety precaution to reduce the chance that Terraform will destroy and recreate
    your S3 bucket, causing COMPLETE LOSS OF ALL DATA even if it was stored in Glacier.
    WARNING: Upgrading this module from a version prior to 0.27.0 to this version
      will cause Terraform to delete your existing S3 bucket CAUSING COMPLETE DATA LOSS
      unless you follow the upgrade instructions on the Wiki [here](https://github.com/cloudposse/terraform-aws-s3-log-storage/wiki/Upgrading-to-v0.27.0-(POTENTIAL-DATA-LOSS)).
      See additional instructions for upgrading from v0.27.0 to v0.28.0 [here](https://github.com/cloudposse/terraform-aws-s3-log-storage/wiki/Upgrading-to-v0.28.0-and-AWS-provider-v4-(POTENTIAL-DATA-LOSS)).
    EOT
  default     = false
}

################################################################################
## cluster
################################################################################
variable "cluster_name_override" {
  type        = string
  description = "Name to assign the cluster. If null, the default will be `namespace-environment-cluster`"
  default     = null
}

################################################################################
## cluster
################################################################################
variable "additional_ssm_params" {
  type = list(object({
    name        = string
    value       = string
    description = string
    type        = string
    overwrite   = bool
  }))
  description = <<-EOF
    Additional SSM Parameters you would like to add for your ECS configuration.
    The optional value defaults are:
      description = "Managed by Terraform"
      type = "SecureString"
      overwrite = true
  EOF
  default     = []
}
