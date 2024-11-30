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

  alb = {
    name = "arc-poc-alb"
    internal = false
  }

  alb_target_group = [{
    name = "arc-poc-alb-tg"
    port = 80
    vpc_id = "vpc-1234"
    health_check = {
      enabled = true
      path = "/"
    }
  }]

  listener_rules = {}
}