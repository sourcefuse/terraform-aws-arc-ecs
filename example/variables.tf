################################################################################
## shared
################################################################################
variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "environment" {
  description = "ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'"
  type        = string
  default     = "poc"
}

variable "namespace" {
  type        = string
  description = "Namespace for the resources."
  default     = "arc"
}

################################################################################
## network / security
################################################################################
variable "private_subnet_names" {
  description = <<-EOF
    List of Private Subnet names in the VPC where the network resources currently exist.
    If not defined, the default value from `terraform-aws-ref-arch-network` will be used.
    From that module's example, the value is: [`example-dev-private-us-east-1a`, `example-dev-private-us-east-1b`]
  EOF
  type        = list(string)
  default     = []
}

variable "public_subnet_names" {
  description = <<-EOF
    List of Public Subnet names in the VPC where the network resources currently exist.
    If not defined, the default value from `terraform-aws-ref-arch-network` will be used.
    From that module's example, the value is: [`example-dev-public-us-east-1a`, `example-dev-public-us-east-1b`]
  EOF
  type        = list(string)
  default     = []
}

variable "vpc_name" {
  description = <<-EOF
    Name of the VPC where the network resources currently exist.
    If not defined, the default value from `terraform-aws-ref-arch-network` will be used.
    From that module's example, the name `example-dev-vpc` is used.
  EOF
  type        = string
  default     = null
}

################################################################################
## acm
################################################################################
variable "acm_domain_name" {
  description = "Domain name the ACM Certificate belongs to"
  type        = string
  default     = "*.arc-poc.link"
}
