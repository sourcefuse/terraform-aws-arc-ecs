terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "alb" {
  source = "../../modules/alb"

  vpc_id = "vpc-12345"

  alb = {
    name     = "arc-poc-alb"
    internal = false
    port     = 80
  }

  alb_target_group = [{
    name     = "arc-poc-alb-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = "vpc-12345"
    health_check = {
      enabled = true
      path    = "/"
    }
  }]

  listener_rules = []
}
