profile                 = "poc2"
vpc_id                  = "vpc-04336471107d1b7c2"
environment             = "dev"
name                    = "ecs-fargate"
health_check_path       = "/status"
alb_security_groups     = [] // Grab from console
subnets                 = ["subnet-02a09c9b7b22ba00a","subnet-0f76d443d6aa1891b"] // Grab from console
alb_tls_cert_arn        = [] // Grab from console
#container_environment   = ""
service_desired_count   = "3"
container_port          = 80
region                  = "us-east-1"
container_image         = "nginx"
container_cpu           = 256
container_memory        = 512


/*
name                = "my-project-name"
environment         = "test"
availability_zones  = ["eu-central-1a", "eu-central-1b"]
private_subnets     = ["10.0.0.0/20", "10.0.32.0/20"]
public_subnets      = ["10.0.16.0/20", "10.0.48.0/20"]
tsl_certificate_arn = "mycertificatearn"
container_memory    = 512
*/