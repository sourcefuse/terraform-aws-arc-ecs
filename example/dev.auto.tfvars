// TODO: these can be pulled in from a data source
vpc_id            = "vpc-04336471107d1b7c2"
environment       = "dev"
name              = "ecs-fargate"
health_check_path = "/"
// TODO: these can be pulled in from a data source
subnets = ["subnet-02a09c9b7b22ba00a", "subnet-0f76d443d6aa1891b"] // Grab from console
// TODO: these can be pulled in from a data source
alb_tls_cert_arn      = "arn:aws:acm:us-east-1:757583164619:certificate/c29d5333-37c8-42a8-ba3c-d0cd6cd5db4b" // Grab from console
service_desired_count = "3"
container_port        = 80
region                = "us-east-1"
container_image       = "nginx"
container_cpu         = 256
container_memory      = 512
// TODO: these can be pulled in from a data source
zone_id  = "Z019267039CEOT4DT8S38"
dns_name = "healthcheck-tester"
