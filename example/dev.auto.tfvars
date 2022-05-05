profile                 = "poc2"
vpc_id                  = "vpc-04336471107d1b7c2"
environment             = "dev"
name                    = "ecs-fargate"
health_check_path       = "/"
alb_security_groups     = [] // Grab from console
subnets                 = ["subnet-02a09c9b7b22ba00a","subnet-0f76d443d6aa1891b"] // Grab from console
alb_tls_cert_arn        = [] // Grab from console
service_desired_count   = "3"
container_port          = 80
region                  = "us-east-1"
container_image         = "nginx"
container_cpu           = 256
container_memory        = 512


