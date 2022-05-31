#variable "profile" {
#  description = "The aws profile to use"
#}

variable "region" {
  description = "The aws region"
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "alb_tls_cert_arn" {
  description = "The ARN of the certificate that the ALB uses for https"
}


variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "subnets" {
  description = "List of subnet IDs"
}

variable "dns_name" {
  description = "Alias record created for LB"
}

variable "zone_id" {
  description = "Route53 zone for alias record"
}
