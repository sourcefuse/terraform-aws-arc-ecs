#variable "profile" {
#  description = "The aws profile to use"
#}

# variable "region" {
#   description = "The aws region"
# }

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
  type = string
}

variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "alb_tls_cert_arn" {
  description = "The ARN of the certificate that the ALB uses for https"
  type = string
}


variable "name" {
  description = "the name of your stack, e.g. \"demo\""
  type = string
}

variable "subnets" {
  description = "List of subnet IDs"
  type = list(string)
}

variable "dns_name" {
  description = "Alias record created for LB"
  type = string
}

variable "zone_id" {
  description = "Route53 zone for alias record"
  type = string
}
