variable "name" {
  default = "default_value"
}

variable "environment" {
  default = ""
}

variable "region" {
  default = "us-east-1"
}

variable "subnets" {
  description = "List of subnet IDs"
  default     = []
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "dns_name" {}

variable "zone_id" {}

variable "alb_tls_cert_arn" {

}

variable "health_check_path" {

}

variable "service_desired_count" {

}

variable "container_port" {

}

variable "container_image" {

}

variable "container_cpu" {

}

variable "container_memory" {

}
