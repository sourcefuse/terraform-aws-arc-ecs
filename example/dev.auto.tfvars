vpc_id               = "sourceloop-dev-vpc"
environment          = "dev"
name                 = "ecs-fargate"
health_check_path    = "/status"
alb_security_groups  = [] // Grab from console
subnets              = [] // Grab from console
alb_tls_cert_arn     = [] // Grab from console
